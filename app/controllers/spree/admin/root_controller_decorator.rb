module Spree
  Spree::Admin::RootController.class_eval do

    def shipping
    end

    def index
      unless spree_current_user
        redirect_to admin_login_url
      end
    end
  end
end
