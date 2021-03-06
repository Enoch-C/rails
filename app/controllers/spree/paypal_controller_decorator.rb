module Spree
  Spree::PaypalController.class_eval do

        def express
          order = current_order || raise(ActiveRecord::RecordNotFound)
          items = order.line_items.map(&method(:line_item))
          additional_adjustments = order.all_adjustments.additional
          tax_adjustments = additional_adjustments.tax
          shipping_adjustments = additional_adjustments.shipping
          
          order.all_adjustments.eligible.each do |adjustment|
            # Because PayPal doesn't accept $0 items at all. See #10
            # https://cms.paypal.com/uk/cgi-bin/?cmd=_render-content&content_ID=developer/e_howto_api_ECCustomizing
            # "It can be a positive or negative value but not zero."
            next if adjustment.amount.zero?
            next if tax_adjustments.include?(adjustment) || shipping_adjustments.include?(adjustment)

            items << {
              Name: adjustment.label,
              Quantity: 1,
              Amount: {
                currencyID: order.currency,
                value: adjustment.amount
              }
            }
          end

          pp_request = provider.build_set_express_checkout(express_checkout_request_details(order, items))

          begin
            pp_response = provider.set_express_checkout(pp_request)
            if pp_response.success?
              redirect_to provider.express_checkout_url(pp_response, useraction: 'commit')
            else
              flash[:error] = Spree.t('flash.generic_error', scope: 'paypal', reasons: pp_response.errors.map(&:long_message).join(" "))
              redirect_to checkout_state_path(:payment)
            end
          rescue SocketError
            flash[:error] = Spree.t('flash.connection_failed', scope: 'paypal')
            redirect_to checkout_state_path(:payment)
          end
        end

  end
end
