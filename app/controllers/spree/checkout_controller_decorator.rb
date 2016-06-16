module Spree
  Spree::CheckoutController.class_eval do
    before_action :ensure_stripe_checkout, only: [:update]

    def ensure_stripe_checkout
      if params[:stripeToken]
        stripe = PaymentMethod.find_by_name("Stripe")
        params[:payment_source][stripe.id.to_s] = { :gateway_payment_profile_id => params[:stripeToken],
          :stripeTokenType => params[:stripeTokenType],
          :stripeEmail => params[:stripeEmail] }
        params.delete(:stripeToken)
        params.delete(:stripeTokenType)
        params.delete(:stripeEmail)
      end
    end
  end
end
