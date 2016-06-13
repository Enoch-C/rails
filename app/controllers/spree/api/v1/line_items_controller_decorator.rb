Spree::Api::V1::LineItemsController.class_eval do

  def update
    @line_item = find_line_item
    @order.contents.remove_line_item(@line_item)
    variant = Spree::Variant.find_by_sku(params[:line_item][:sku])
    @line_item = order.contents.add(
              variant,
              params[:line_item][:quantity] || 1,
              #line_item_params[:options] || {}
              {}
          )
    if @line_item.errors.empty?
      respond_with(@line_item, default_template: :show)
    else
      invalid_resource!(@line_item)
    end 
  end

  #def update
    #@line_item = find_line_item
    #attributes = line_items_attributes

    # update line_item's belongs_to relation with variant though AR's attributes update, however inventory and prices are not updated.
    #variant = Spree::Variant.find_by_sku(params[:line_item][:sku])
    #attributes[:line_items_attributes][:variant] = variant

    #if @order.contents.update_cart(attributes)
      #@line_item.reload
      #respond_with(@line_item, default_template: :show)
    #else
      #invalid_resource!(@line_item)
    #end
  #end

end
