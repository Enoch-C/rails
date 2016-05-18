class AddPromoterIdToSpreeOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :promoter_id, :integer
    add_index  :spree_orders, :promoter_id
  end
end
