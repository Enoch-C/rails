Spree::Admin::OrdersController.class_eval do
  before_action :load_promoters_data, only: [:index]

  def load_promoters_data
    @promoters = Spree::Promoter.order(:email)
  end

  def labels
    load_order
  end
end
