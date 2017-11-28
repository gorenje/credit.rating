get '/transactions/:account_id' do
  @account      = get_account
  @transactions = @account.transactions

  haml :transactions
end

get '/transactions/graph/:account_id' do
  @account = get_account

  haml :transactions_graph
end

get '/add_transactions/:account_id' do
  @account = get_account

  haml :transactions_upload
end

post '/add_transactions/:account_id' do
  key       = OpenSSL::PKey::RSA.new(ENV['RSA_PRIVATE_KEY'].gsub(/\\n/, "\n"))
  data      = JSON(JWE.decrypt(params[:creds], key))
  file_data = Base64::decode64(data["filedata"].sub(/^.+base64,/, ''))
  account   = get_account

  impClass = TransactionImporter.handler_for(file_data)
  importer = impClass.new(account)
  importer.import(file_data)

  redirect "/transactions/graph/#{account.id}"
end
