Spree::Order.class_eval do
  belongs_to :promoter, foreign_key: :promoter_id, class_name: "Spree::Promoter"
  self.whitelisted_ransackable_attributes.push('promoter_id')

  checkout_flow do
    go_to_state :message, if: ->(order) { order.special_instructions }
    go_to_state :address
    go_to_state :delivery#, unless: ->(order) { order.special_instructions }
    go_to_state :payment, if: ->(order) { order.payment_required? }
    #go_to_state :confirm, if: ->(order) { order.confirmation_required? }
    go_to_state :complete
    remove_transition from: :delivery, to: :confirm
  end

  def generate_order_number
   self.number = "R#{Time.now.to_i}#{Array.new(5){rand(9)}.join}" if self.number.blank?
   self.number
  end

  def deliver_order_confirmation_email
    if special_instructions
      Spree::OrderMailer.confirm_gift_email(id).deliver_later
    end

    Spree::OrderMailer.confirm_email(id).deliver_later
    Spree::OrderMailer.confirm_email_to_staff(id).deliver_later
    update_column(:confirmation_delivered, true)

    order_promoter = self.promoter
    unless order_promoter
      promotions.each do |p|
        if p.promoter
          order_promoter = p.promoter
        end
      end
    end

    if user.order_count == 1
      if order_promoter
        user.promoter = order_promoter
        user.promoter_start = Time.now
        user.promoter_month_length = 12
      end
    else
      if user.promoter
        if user.promoter == order_promoter
          user.promoter_start = Time.now
          user.promoter_month_length = 12
        end
      end
    end

    # credit commission
    if user.promoter
      if user.promoter_start + user.promoter_month_length.months > Time.now
        # in bind
        credit_amount = 0.0
        if line_items.any?
          line_items.each do |line|
            if line.product.sku.start_with?("ccsm")
              credit_amount += 5.00 * line.quantity
            elsif line.product.sku.start_with?("ccsw")
              credit_amount += 1.50 * line.quantity
            end
          end
        end
        if user.promoter.children.count > 0
          credit_amount += credit_amount/2.5
        end
        user.promoter.store_credit += credit_amount
        self.promoter = user.promoter
        user.promoter.save
        user.save
        self.save
        if credit_amount > 0
          if user.promoter.children.count > 0
            Spree::OrderMailer.confirm_promoter_pro_email(user.promoter, credit_amount).deliver_later
          else
            Spree::OrderMailer.confirm_promoter_email(user.promoter, credit_amount).deliver_later
          end
          if user.promoter.parent
            user.promoter.parent.store_credit += credit_amount/2.5
            user.promoter.parent.save
            Spree::OrderMailer.confirm_promoter_parent_email(user.promoter, credit_amount).deliver_later
            if user.promoter.parent.parent
              Spree::OrderMailer.confirm_promoter_parent_parent_email(user.promoter, credit_amount).deliver_later
              if user.promoter.parent.parent.parent
                Spree::OrderMailer.confirm_promoter_parent_parent_parent_email(user.promoter, credit_amount).deliver_later
              end
            end
          end

        end
      else
        # outdate bind
      end
    end
  end
end
