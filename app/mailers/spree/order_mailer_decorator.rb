Spree::OrderMailer.class_eval do
  def confirm_promoter_email(promoter, credit_amount, resend = false)
    @promoter = promoter
    subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
    subject += "#{Spree::Store.current.name}: #{Spree.t('order_mailer.confirm_promoter_email.subject')} - $#{credit_amount}"
    mail(to: @promoter.email, from: from_address, subject: subject)
  end

  def confirm_gift_email(order, resend = false)
    @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
    si = eval(@order.special_instructions)
    subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
    subject += "Dear #{si[:recipient_name]}, #{Spree.t('order_mailer.confirm_gift_email.subject')} #{si[:my_name]}!"
    mail(to: si[:recipient_email], from: from_address, subject: subject)
  end

  def confirm_wish_email(wish, resend = false)
    subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
    subject += "New wish from customer"
    mail(to: from_address, from: from_address, subject: subject) do |format|
      format.text { render plain: wish }
      format.html { render html: wish.html_safe }
    end
  end
end
