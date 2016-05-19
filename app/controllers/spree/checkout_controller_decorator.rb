Spree::CheckoutController.class_eval do
  # # Updates the order and advances to the next state (when possible.)
  # def update
  #   if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
  #     @order.temporary_address = !params[:save_user_address]
  #     unless @order.next
  #       flash[:error] = @order.errors.full_messages.join("\n")
  #       redirect_to(checkout_state_path(@order.state)) && return
  #     end
  #
  #     if @order.completed?
  #       @current_order = nil
  #       flash.notice = Spree.t(:order_processed_successfully)
  #       flash['order_completed'] = true
  #       redirect_to completion_route
  #     else
  #       redirect_to checkout_state_path(@order.state)
  #     end
  #   else
  #     render :edit
  #   end
  # end

  private
  # Introduces a registration step whenever the +registration_step+ preference is true.
  def check_registration
    return unless Spree::Auth::Config[:registration_step]
    return if spree_current_user or current_order.email
    store_location
    redirect_to spree.login_path
  end
end
