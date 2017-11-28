module FigoHelper
  extend self

  def get_banks
    start_session.get_supported_payment_services("DE","banks")["banks"]
  end

  def get_services
    start_session.get_supported_payment_services("DE","services")["services"]
  end

  def start_session
    data = $figo_connection.
      credential_login(ENV['FIGO_USERNAME'],ENV['FIGO_PASSWORD'])

    Figo::Session.new(data["access_token"])
  end
end
