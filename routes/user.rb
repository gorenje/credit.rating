get '/profile' do
  @user = User.find(session[:user_id])
  @user.update_rating if @user.rating.nil?
  haml :profile
end

post '/profile' do
  session[:message] = "Successfully Updated"

  User.find(session[:user_id]).update(:name => params[:username])

  redirect '/profile'
end

get '/users/email-confirmation' do
  session[:message] = params[:r]
  haml :"email_confirmation"
end

get '/user/emailconfirm' do
  if params_blank?(:email,:token)
    redirect to_email_confirm("MissingData")
  else
    email, salt = extract_email_and_salt(params[:email])
    if email.blank? or salt.blank?
      redirect to_email_confirm("DataCorrupt")
    end

    user = User.find_by_email(email)
    redirect(to_email_confirm("EmailUnknown")) if user.nil?

    if user.email_confirm_token_matched?(params[:token], salt)
      user.update(:has_confirmed => true, :confirm_token => nil)
      session[:email] = user.email
      session[:message] = "Email Confirmed!"
      redirect "/login"
    else
      redirect to_email_confirm("TokenMismatch")
    end
  end
end
