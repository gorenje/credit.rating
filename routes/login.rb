get '/login' do
  @email = session.delete(:email)
  haml :login
end

get '/register' do
  haml :register
end

get '/resend/email/:eid' do
  if user = User.find_by_external_id(params[:eid])
    unless user.has_confirmed?
      confirm_link = user.generate_email_confirmation_link

      session[:message] =
        if ENV["MANDRILL_API_KEY"].empty?
          "Mandrill not configured, <a href='"  +
            confirm_link + "'>Click here</a> to confirm email."
        else
          Mailer::Client.new.
            send_confirm_email({"confirm_link" => confirm_link,
                                "email"        => user.email,
                                "firstname"    => user.name,
                                "lastname"     => ""})
          "Confirmation Email resent."
        end
    else
      session[:message] = "Email already confirmed, <a href='/login'>"+
        "Login</a>."
    end
  else
    session[:message] = "Unknown User"
  end
  haml :"email_confirmation"
end

post '/login' do
  key = OpenSSL::PKey::RSA.new(ENV['RSA_PRIVATE_KEY'].gsub(/\\n/,"\n"))
  data = JSON(JWE.decrypt(params[:creds], key))

  case data["type"]
  when "register"
    if u = User.where(:email => data["email"].downcase).first
      session[:message] = if u.has_confirmed?
                            "Email already registered, <a href='/login'>"+
                              "Login</a>."
                          else
                            "Email already registered, <a href='/resend/"+
                              "email/#{u.external_id}'>Resend Email</a>."
                          end
      @email = data["email"]
      @name = data["name"]
    else
      if data["password1"] != data["password2"]
        session[:message] = "Passwords did not match"
        @email = data["email"]
        @name = data["name"]
      else
        u = User.create(:email => data["email"].downcase,
                        :name => data["name"])

        u.password   = data["password1"]
        confirm_link = u.generate_email_confirmation_link

        session[:message] =
          if ENV["MANDRILL_API_KEY"].empty?
            "Mandrill not configured, <a href='"  +
              confirm_link + "'>Click here</a> to confirm email."
          else
            Mailer::Client.new.
              send_confirm_email({"confirm_link"  => confirm_link,
                                  "email"         => u.email,
                                  "firstname"     => u.name,
                                  "lastname"      => ""})
            "Thank You! Confirmation email has been sent." +
              "Once you have confirmed your email, you may " +
              "login."
          end
      end
    end
    haml :register

  when "login"
    if user = User.where(:email => data["email"].downcase).first
      if user.has_confirmed?
        if user.password_match?(data["password"])
          user.create_or_update_figo_account rescue nil
          session[:user_id] = user.id
          redirect "/"
        else
          @email = data["email"]
          session[:message] = "Unknown Email or Wrong Password - take your pick"
        end
      else
        @email = data["email"]
        session[:message] = "Email not yet confirmed, check your inbox"
      end
    else
      @email = data["email"]
      session[:message] = "Unknown Email or Wrong Password - take your pick"
    end
    haml :login

  else
    session[:message] = "Unknown Interaction With Server"
    haml :login
  end
end
