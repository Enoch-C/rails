module Spree
  class GiftController < Spree::StoreController
    helper 'spree/orders'
    respond_to :html

    def index
      @order = current_order(create_order_if_necessary: true)
      @order.empty!
      @order.special_instructions = "Dear,"
    end
  end
end
