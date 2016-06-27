Spree::User.class_eval do
  belongs_to :promoter, foreign_key: :promoter_id, class_name: "Spree::Promoter"
  after_create :new_customer_welcome

  private

  def new_customer_welcome
    Spree::OrderMailer.confirm_reg_email(email).deliver_later
  end
end
