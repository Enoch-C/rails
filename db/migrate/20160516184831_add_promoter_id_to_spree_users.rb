class AddPromoterIdToSpreeUsers < ActiveRecord::Migration
  def change
    add_column :spree_users, :promoter_id, :integer
    add_column :spree_users, :promoter_start, :datetime
    add_column :spree_users, :promoter_month_length, :integer, default: 12
    add_index  :spree_users, :promoter_id
  end
end
