module Spree
  class GiftController < Spree::StoreController
    helper 'spree/orders'
    respond_to :html

    def index
    end
  end
end
