Spree::User.class_eval do
  belongs_to :promoter, foreign_key: :promoter_id, class_name: "Spree::Promoter"
end
