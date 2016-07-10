module Spree
  Spree::BaseMailer.class_eval do
    def mail(headers = {}, &block)
      if headers[:to].start_with?("86") && headers[:to].end_with?("@coolchoice.com")
        headers[:subject] += "手机#{headers[:to][2,11]}"
        headers[:to]= Rails.application.config.customer_service_email[0]
      end
      ensure_default_action_mailer_url_host
      super if Spree::Config[:send_core_emails]
    end
  end
end
