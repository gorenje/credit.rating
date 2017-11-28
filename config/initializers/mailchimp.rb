require 'mailchimp'

$mailer = Mailchimp::Mandrill.new(ENV['MANDRILL_API_KEY'])
