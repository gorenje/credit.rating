get '/figo/login' do
  redirect $figo_connection.
    login_url("qweqwe", "accounts=ro transactions=ro balance=ro user=ro")
end

get '/callback*' do
  if params['state'] != "qweqwe"
    raise Exception.new("Bogus redirect, wrong state")
  end

  token_hash = $figo_connection.obtain_access_token(params['code'])

  user = User.find(session[:user_id])
  user.figo_access_token = token_hash['access_token']
  user.login_token = params['code']

  redirect "/accounts"
end

get '/update_accounts_from_figo' do
  User.find(session[:user_id]).update_accounts_from_figo rescue nil
  redirect '/accounts'
end

get '/logout' do
  session.delete(:user_id)
  redirect '/'
end
