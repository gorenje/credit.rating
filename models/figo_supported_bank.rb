class FigoSupportedBank < ActiveRecord::Base
  def self.get_bank(iban)
    return nil unless IBANTools::IBAN.valid?(iban.code)
    return nil if iban.country_code != 'DE'

    FigoSupportedBank.where(:bank_code => iban.to_local[:blz]).first
  end

  def credentials
    JSON(details_json)["credentials"]
  end

  def icon
    JSON(details_json)["icon"]
  end
end
