module Spree
  class GiftController < Spree::StoreController

    def index
      order = current_order(create_order_if_necessary: true)
      order.empty!
      variant = Spree::Variant.find_by_sku("ccsm0000")
      quantity = 1 
      options  = params[:options] || {}

        begin
          order.contents.add(variant, quantity, options)
          order.update_attributes({:special_instructions => "{}"})
        rescue ActiveRecord::RecordInvalid => e
          error = e.record.errors.full_messages.join(", ")
        end
    end
    
    def my_gift
      order_token = params[:token]
      @order = Spree::Order.find_by_guest_token(order_token)
    end

    def my_gift_shipping_address
      order_token = params[:token]
      @order = Spree::Order.find_by_guest_token(order_token)
    end
    
  end
end
