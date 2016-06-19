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
        rescue ActiveRecord::RecordInvalid => e
          error = e.record.errors.full_messages.join(", ")
        end
    end
  end
    
end
