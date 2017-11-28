get '/accounts' do
  @accounts = User.find(session[:user_id]).accounts

  haml :accounts
end

get '/account/delete/:account_id' do
  get_account.tap do |acc|
    acc.transactions.delete_all
    acc.delete
  end

  redirect '/accounts'
end

get '/account/refresh/:account_id' do
  get_account.refresh
  redirect "/transactions/#{params[:account_id]}"
end

get '/add_account' do
  haml :add_account
end

post '/add_account' do
  user = User.find(session[:user_id])
  iban = if IBANTools::IBAN.valid?(params[:iban])
           IBANTools::IBAN.new(params[:iban])
         else
           session[:message] = "IBAN: #{params[:iban]} is not valid"
           redirect "/add_account"
         end

  if iban.country_code != "DE"
    session[:message] = "IBAN: #{params[:iban]} is not a german account"
    redirect "/add_account"
  end

  account = user.accounts.where(:iban => iban.code).first ||
    Account.create(:user           => user,
                   :iban           => iban.code,
                   :name           => user.name,
                   :owner          => user.name,
                   :account_number => iban.to_local[:account_number],
                   :currency       => 'EUR',
                   :bank           => Bank.for_iban(iban))

  if params[:creds] == "upload_instead"
    redirect "/add_transactions/#{account.id}"
  else
    account.figo_credentials = params[:creds]

    begin
      task = account.add_account_to_figo
    rescue Figo::Error => e
      session[:message] = "Error Adding #{iban.code}: #{e.message}"
      redirect "/add_account"
    end

    session[:message] = "Your account at #{account.bank.name} will be " +
      "updated presently"
    redirect '/accounts'
  end
end

post '/iban/check' do
  return_json do
    { :r => IBANTools::IBAN.valid?(params[:iban]) }
  end
end

post '/iban/bankdetails' do
  return_json do
    iban = IBANTools::IBAN.new(params[:iban])

    { :form => haml(:"_figo_bank_form", :layout => false,
                    :locals => {
                      :bank => FigoSupportedBank.get_bank(iban),
                      :iban => iban
                    })
    }
  end
end
