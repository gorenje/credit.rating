require 'adtekio_utilities'

if ENV['CRED_KEY_BASE64'].nil? || ENV['CRED_IV_BASE64'].nil?
  puts "WARNING: Not initialising Encryption"
else
  AdtekioUtilities::Encrypt.configure do |c|
    c.base64_key = ENV['CRED_KEY_BASE64']
    c.base64_iv  = ENV['CRED_IV_BASE64']
    c.pepper     = ENV['PASSWORD_PEPPER'] || 'pepper'
  end
end
