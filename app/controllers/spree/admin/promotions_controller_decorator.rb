Spree::Admin::PromotionsController.class_eval do
  def load_data
    @calculators = Rails.application.config.spree.calculators.promotion_actions_create_adjustments
    @promotion_categories = Spree::PromotionCategory.order(:name)
    @promoters = Spree::Promoter.order(:email)
  end
end
