module Spree
  Spree::HomeController.class_eval do
    skip_before_action :verify_authenticity_token, only: [:wish]

    def wish
      unless params[:wish] == ""
        Spree::OrderMailer.confirm_wish_email(params[:wish]).deliver_later
      end
      render :index
    end

  end
end