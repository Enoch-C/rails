Spree::StoreController.class_eval do
  protected

  # This method is placed here so that the CheckoutController
  # and OrdersController can both reference it (or any other controller
  # which needs it)
  def apply_coupon_code
    if params[:order] && params[:order][:coupon_code]
      @order.coupon_code = params[:order][:coupon_code]

      handler = Spree::PromotionHandler::Coupon.new(@order).apply

      if handler.error.present?
        flash.now[:error] = handler.error
        respond_with(@order) { |format| format.html { render :edit } } and return
      elsif handler.success
        flash[:success] = handler.success and return
      end
    end
  end

end
