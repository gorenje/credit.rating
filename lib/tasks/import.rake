namespace :import do
  desc <<-EOF
    Import all banks supported by figo.
  EOF
  task :figo_supported_stuff do
    ((FigoHelper.get_banks rescue []) + [FigoDemoBank]).each do |bnk|
      FigoSupportedBank.where(:bank_code => bnk["bank_code"]).
        first_or_create.
        update(:bank_name    => bnk["bank_name"],
               :advice       => bnk["advice"],
               :bic          => bnk["bic"],
               :details_json => bnk.to_json)
    end

    FigoHelper.get_services.each do |srv|
      FigoSupportedService.where(:bank_code => srv["bank_code"]).
        first_or_create.
        update(:name         => srv["name"],
               :advice       => srv["advice"],
               :details_json => srv.to_json)
    end rescue nil
  end

  desc <<-EOF
    Import account and transaction data for all users.
  EOF
  task :from_figo do
    Account.all.map(&:figo_task) rescue nil
    User.all.each do |user|
      next unless user.has_figo_account?
      puts "Import #{user.name} / #{user.email}"
      user.update_accounts_from_figo
    end
  end
end
