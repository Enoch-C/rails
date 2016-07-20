module Spree
  class LabelgenController < Spree::StoreController
    def index
    end

    def labels
      sku = params["sku"]
      quantity = params["quantity"]
      variant = Spree::Variant.find_by_sku("ccsd3f" + sku)

      @order = Spree::Order.new
      @line_item = @order.contents.add(
          variant,
          quantity,
          {}
      )
    end

  end
end
