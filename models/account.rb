class Account < ActiveRecord::Base
  belongs_to :bank
  belongs_to :user
  has_many :transactions, :dependent => :destroy

  include ModelHelpers::CredentialsHelper

  class << self
    def in_credit
      where("last_known_balance > 0")
    end
  end

  def newest_transaction_id
    transactions.pluck(:transaction_id).
      sort_by { |str| str =~ /([0-9]+)$/ && $1.to_i }.last
  end

  def figo_credentials=(val)
    self.creds = self.creds.merge("figo_creds" => val)
  end

  def figo_credentials
    (self.creds || {})["figo_creds"]
  end

  def figo_task_token=(val)
    self.creds = self.creds.merge("figo_task_token" => val)
  end

  def figo_task_token
    (self.creds || {})["figo_task_token"]
  end

  def iban_valid?
    IBANTools::IBAN.valid?(iban)
  end

  def iban_obj
    IBANTools::IBAN.new(iban)
  end

  def is_figo_connected?
    !figo_credentials.empty?
  end

  def is_service?
    account_number.blank?
  end

  def add_account_to_figo
    credentials = { "type" => "encrypted", "value" => figo_credentials }

    if is_service?
      user.start_figo_session.
        add_account("de", credentials, iban, nil, true)
    else
      user.start_figo_session.
        add_account("de", credentials, iban_obj.to_local[:blz],
                    iban_obj.code, true)
    end.tap do |t|
      self.figo_task_token = t.task_token
    end
  end

  def figo_task
    return nil if figo_task_token.nil?
    user.start_figo_session.
      get_task_state( OpenStruct.new(:task_token => figo_task_token))
  end

  def refresh
    return unless user.has_figo_account?
    user.update_accounts_from_figo
  end

  def previous_account
    accs = user.accounts.order(:id)
    pos = accs.index(self)
    pos - 1 < 0 ? accs.last : accs[pos-1]
  end

  def next_account
    accs = user.accounts.order(:id)
    pos = accs.index(self)
    pos + 1 >= accs.size ? accs.first : accs[pos+1]
  end

  def update_from_figo_account(acc, dbbank)
    update(:owner              => acc.owner || user.name,
           :name               => acc.name,
           :account_type       => acc.type,
           :currency           => acc.currency,
           :iban               => acc.iban,
           :account_number     => acc.account_number,
           :icon_url           => acc.icon,
           :bank               => dbbank,
           :last_known_balance => acc.balance.balance.to_s,
           :save_pin           => acc.bank.save_pin,
           :sepa_creditor_id   => acc.bank.sepa_creditor_id)
  end

  def cluster_transactions_by_month(filter = :none)
    trans = transactions.filter(filter)
    ary   = trans.map(&:booking_date).sort
    return {} if ary.empty?

    {}.tap do |hsh|
      (ary.first..ary.last).
        map { |a| a.strftime("%Y%m") }.
        uniq.each do |month|
        hsh[month] = { "debit" => [], "credit" => [], "all" => [] }
      end
    end.tap do |hsh|
      trans.
        group_by { |tran| tran.booking_date.strftime("%Y%m") }.
        each do |month, transactions|
        hsh[month] = {
          "debit"  => transactions.select(&:debit?),
          "credit" => transactions.select(&:credit?),
          "all"    => transactions
        }
      end
    end
  end
end
