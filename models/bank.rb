class Bank < ActiveRecord::Base
  has_many :accounts

  def self.for_iban(iban)
    return nil if iban.country_code != 'DE'

    blz = iban.to_local[:blz]

    Bank.where(:iban_bank_code => blz).first ||
      Bank.create(:iban_bank_code => blz,
                  :iban_bank_name => BlzSearch.find_bank_name(iban))
  end

  def self.for_service(service)
    Bank.where(:iban_bank_code => service.bank_code).first ||
      Bank.create(:iban_bank_code => service.bank_code,
                  :iban_bank_name => service.bank_name)
  end

  def self.paypal
    Bank.where(:iban_bank_code => "paypal").first ||
      Bank.create(:iban_bank_code => "paypal",
                  :iban_bank_name => "Paypal")
  end

  def login_url
    BankLoginURLs[iban_bank_code]
  end

  def name
    iban_bank_name || figo_bank_name
  end
end
