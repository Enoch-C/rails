Spree::OrderMailer.class_eval do
  def confirm_promoter_email(promoter, credit_amount, resend = false)
    @promoter = promoter
    subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
    subject += "#{Spree::Store.current.name}: #{Spree.t('order_mailer.confirm_promoter_email.subject')} - $#{credit_amount}"
    mail(to: @promoter.email, from: from_address, subject: subject)
  end
end
