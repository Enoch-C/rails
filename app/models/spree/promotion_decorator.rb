Spree::Promotion.class_eval do
  belongs_to :promoter, foreign_key: :promoter_id, class_name: "Spree::Promoter"
  self.whitelisted_ransackable_attributes.push('promoter_id')
end
