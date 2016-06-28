Spree::Api::V1::OrdersController.class_eval do
    def update

      if params[:order][:dummy_ship_address]
        country = Spree::Country.find(params[:order][:ship_address_attributes][:country_id].to_i)
        zip = TwitterCldr::Shared::PostalCodes.for_territory(country.iso).sample(1).first
        state = country.states.first
        params[:order][:ship_address_attributes][:state_id] = state.id.to_s
        params[:order][:ship_address_attributes][:zipcode] = zip
      end

      find_order(true)
      authorize! :update, @order, order_token

      if @order.contents.update_cart(order_params)
        user_id = params[:order][:user_id]
        if current_api_user.has_spree_role?('admin') && user_id
          @order.associate_user!(Spree.user_class.find(user_id))
        end
        respond_with(@order, default_template: :show)
      else
        invalid_resource!(@order)
      end
    end
end
