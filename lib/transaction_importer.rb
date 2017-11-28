require 'csv'
require 'cmxl'
require 'bank_account_import'

module TransactionImporter
  extend self

  class Handler
    attr_reader :account

    class << self
      attr_reader :subclasses

      def inherited(sub)
        (@subclasses ||= []) << sub
      end

      def supported?(csv_content)
        false
      end

      def find_importer_for(file_content)
        @subclasses.select { |klazz| klazz.supported?(file_content) }.first
      end
    end

    def initialize(account)
      @account = account
    end
  end

  class BankAccountImportHandler < Handler
    def self.supported?(file_content)
      !!BankAccountImport::BaseImporter.find_importer_for(file_content)
    end

    def import(data)
      imp_klazz = BankAccountImport::BaseImporter.find_importer_for(data)
      details, transactions = imp_klazz.import_data(data)

      puts details.owner

      update_hash = {}.tap do |h|
        h[:currency]           = details.currency || @account.currency
        h[:iban]               = details.iban || @account.iban
        h[:owner]              = details.owner || @account.owner
        h[:last_known_balance] = details.closing_amount ||
                                            @account.last_known_balance
        h[:account_number]     = details.account_number ||
                                            @account.account_number
      end
      @account.update(update_hash)

      transactions.each do |trans|
        dbtrans = Mt940Transaction.
          where( :transaction_id => trans.sha,
                 :account        => @account).first_or_create

        dbtrans.update(:amount            => trans.amount,
                       :currency          => trans.currency,
                       :booking_date      => trans.booking_date,
                       :booking_text      => trans.description,
                       :name              => trans.recipient,
                       :purpose           => trans.description,
                       :transaction_type  => trans.type,
                       :booked            => true,
                       :value_date        => trans.entry_date,
                       :extras            => trans.to_h)
      end
    end
  end

  class Mt940Handler < Handler
    def self.supported?(file_content)
      (Cmxl.parse(file_content, :encoding => "ISO-8859-1") && true) rescue false
    end

    def import(data)
      Cmxl.parse(data, :encoding => "ISO-8859-1").each do |stmt|
        stmt.transactions.each do |trans|
          if cb = stmt.closing_balance
            @account.update(:currency           => cb.currency,
                            :last_known_balance => cb.amount)
          end

          dbtrans = Mt940Transaction.
            where( :transaction_id => trans.sha,
                   :account        => @account).first_or_create

          dbtrans.update( :name         => trans.name,
                          :amount       => trans.sign * trans.amount,
                          :booking_date => trans.date,
                          :value_date   => trans.entry_date,
                          :extras       => trans.sub_fields,
                          :booking_text => trans.description,
                          :purpose      => trans.information,
                          :currency     => @account.currency,
                          :booked       => true)
        end
      end
    end
  end

  ##
  ## Define this class as last since it supports all formats and
  ## becomes the fallback handler if none of the others support the
  ## file contents.
  ##
  class UnknownFormat < Handler
    def self.supported?(file_content)
      true
    end

    def import(data)
      raise ErrorPage::FormatNotSupported.new("Unknown Format")
    end
  end

  def handler_for(data)
    Handler.find_importer_for(data)
  end
end
