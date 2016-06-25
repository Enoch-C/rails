Spree::Api::V1::LineItemsController.class_eval do

  def update
    if params[:skuChanged] == "true"
      @line_item = find_line_item
      @order.contents.remove_line_item(@line_item)
      variant = Spree::Variant.find_by_sku(params[:line_item][:sku])
      @line_item = @order.contents.add(
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
    else 
      @line_item = find_line_item
      if @order.contents.update_cart(line_items_attributes)
        @line_item.reload
        respond_with(@line_item, default_template: :show)
      else
        invalid_resource!(@line_item)
      end
    end
  end

  def create

    if params[:gift]
      order.line_items.each{|item|
        order.contents.remove_line_item(item)
      }
    end 

    variant = nil
    if params[:line_item][:variant_id]
      variant = Spree::Variant.find(params[:line_item][:variant_id])
    elsif params[:line_item][:sku]
      variant = Spree::Variant.find_by_sku(params[:line_item][:sku])
    end

    @line_item = order.contents.add(
        variant,
        params[:line_item][:quantity] || 1,
        line_item_params[:options] || {}
    )

    if @line_item.errors.empty?
      respond_with(@line_item, status: 201, default_template: :show)
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
