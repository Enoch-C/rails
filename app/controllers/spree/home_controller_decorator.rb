module Spree
  Spree::HomeController.class_eval do
    skip_before_action :verify_authenticity_token, only: [:wish]

    def index
      @searcher = build_searcher(params.merge(include_images: true))
      @products = @searcher.retrieve_products.includes(:possible_promotions)
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      if params["p"]
        cookies[:cc_p] = {
           :value => params["p"],
           :expires => 7.days.from_now,
         }
      end
    end
  end
end
