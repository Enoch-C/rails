Spree::Api::V1::OrdersController.class_eval do
    def update
      if params[:order][:dummy_ship_address]
        country = Spree::Country.find(params[:order][:ship_address_attributes][:country_id].to_i)
        temp_iso = country.iso.downcase.to_s.to_sym
        zip = "0"
        zip = TwitterCldr::Shared::PostalCodes.for_territory(temp_iso).sample(1).first if TwitterCldr::Shared::PostalCodes.territories.include?(temp_iso)
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
