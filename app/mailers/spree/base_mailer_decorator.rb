module Spree
  Spree::OrderMailer.class_eval do
    def mail(headers = {}, &block)
      return if headers[:to].start_with?("86") && headers[:to].end_with?("@coolchoice.com")
      ensure_default_action_mailer_url_host
      super if Spree::Config[:send_core_emails]
    end
  end
end
