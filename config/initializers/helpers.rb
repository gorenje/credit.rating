require 'jwe'
require 'digest/sha2'
require 'iban-tools'

# if this crashes, then the RSA_PRIVATE_KEY isn't set correctly.
if ENV['RSA_PRIVATE_KEY']
  OpenSSL::PKey::RSA.new(ENV['RSA_PRIVATE_KEY'].gsub(/\\n/,"\n"))
end
