class FigoSupportedService < ActiveRecord::Base
  def credentials
    JSON(details_json)["credentials"]
  end

  def icon
    ["", JSON(details_json)["additional_icons"]]
  end

  def bank_name
    name
  end
end
