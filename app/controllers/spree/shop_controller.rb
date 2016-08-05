module Spree
  class ShopController < Spree::StoreController
    helper 'spree/products'
    respond_to :html

    skip_before_action :verify_authenticity_token, only: [:wish]

    def wish
      unless params[:wish] == ""
        Spree::OrderMailer.confirm_wish_email(params[:wish]).deliver_later
      end
      render :index
    end

    def index
      @searcher = build_searcher(params.merge(include_images: true))
      @products = @searcher.retrieve_products.includes(:possible_promotions)
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end

  end
end
