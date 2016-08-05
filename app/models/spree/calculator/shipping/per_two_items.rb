require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class PerTwoItems < ShippingCalculator
      preference :amount, :decimal, default: 0
      preference :currency, :string, default: ->{ Spree::Config[:currency] }

      def self.description
        Spree.t(:shipping_flat_rate_per_two_items)
      end

      def compute_package(package)
        compute_from_quantity((package.contents.sum(&:quantity)-1) / 2 + 1)
      end

      def compute_from_quantity(quantity)
        self.preferred_amount * quantity
      end
    end
  end
end
