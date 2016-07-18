module Spree
  Spree::CheckoutController.class_eval do
    before_action :ensure_stripe_checkout, only: [:update]

    # def before_delivery
    #   @order.next
    #   redirect_to checkout_state_path(@order.state)
    # end

    private

    def ensure_stripe_checkout
      if params[:stripeToken]
        stripe = PaymentMethod.find_by_type("Spree::Gateway::StripeGateway")
        unless params[:payment_source]
          params[:payment_source] = {}
        end
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
