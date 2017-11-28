module Mailer
  class Client
    def send_confirm_email(details)
      send_message do
        details.merge("slug"     => "deutsche-bonitaet-confirm-email",
                      "subject"  => subject_line(details,"Email Confirmation"),
                      "cc_email" => {
                        :email => "emailconfirm@adtek.io",
                        :name  => "Deutsche Bonitaet Email Confirm"
                      })
      end
    end

    protected

    def subject_line(details, postfix)
      "%s %s - Deutsche Bonitaet %s" % [details["firstname"], details["lastname"], postfix]
    end

    def name_for_template_id(slugstr)
      $mailer.templates_list.
        select { |a| a["slug"] == slugstr }.first["name"]
    end

    def to_emails(details)
      [{ :email => details["email"],
         :name  => "%s %s" % [details["firstname"],details["lastname"]]}]
    end

    def send_message
      details = yield
      begin
        $mailer.messages_send_template(construct_hash(details))
      rescue Exception => e
        puts "Failed to send EMAIL: #{details} / #{e}"
      end
    end

    def global_template_vars(details)
      details.keys.map do |key|
        { :name => key, :content => details[key] }
      end +
        [{ :name => "username",  :content => details["email"] },
         { :name => "firstname", :content => details["firstname"].capitalize},
         { :name => "lastname",  :content => details["lastname"].capitalize}]
    end

    def construct_hash(details)
      {
        :template_name    => name_for_template_id(details["slug"]),
        :template_content => [{ :name => "not", :value => "needed"},
                              { :name => "but", :value => "required"}],
        :message => {
          :from_email          => "billing@adtek.io",
          :from_name           => "Deutsche Bonitaet",
          :to                  => to_emails(details) << details["cc_email"],
          :preserve_recipients => nil,
          :subject             => details["subject"],
          :global_merge_vars   => global_template_vars(details),
          :merge_vars          => []
        }
      }
    end
  end
end
