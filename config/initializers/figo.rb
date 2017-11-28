require 'figo'

$figo_connection = Figo::Connection.new(ENV['FIGO_CLIENT_ID'],
                                        ENV['FIGO_CLIENT_SECRET'],
                                        ENV['FIGO_REDIRECT_URL'])
