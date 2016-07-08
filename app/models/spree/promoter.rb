module Spree
  class Promoter < Spree::Base
    validates :email, uniqueness: true
    validates :email, :last_name, :first_name, :percent, :store_credit, presence: true
    has_many :orders, foreign_key: :promoter_id, class_name: "Spree::Order"
    has_many :promotions, foreign_key: :promoter_id, class_name: "Spree::Promotion"
    has_many :users, foreign_key: :promoter_id, class_name: "Spree::User"

    belongs_to :parent, foreign_key: :parent_id, class_name: "Spree::Promoter"
    has_many :children, foreign_key: :parent_id, class_name: "Spree::Promoter"

    attr_accessor :parent_email

    def parent_email=(parent_email)
      self.parent = Spree::Promoter.find_by_email(parent_email)
    end

    def parent_email
      return nil unless parent
      parent.email
    end

    extend DisplayMoney
    money_methods :lifetime_value, :average_order_value, :total_available_store_credit

    def lifetime_value
      orders.complete.sum(:total)
    end

    def order_count
      BigDecimal(orders.complete.size)
    end

    def total_available_store_credit
      store_credit
    end

    def average_order_value
      if order_count.to_i > 0
        lifetime_value / order_count
      else
        BigDecimal("0.00")
      end
    end

    self.whitelisted_ransackable_attributes =  %w[email phone first_name last_name identity]

    promoters_table_name = Promoter.table_name
  end
end
