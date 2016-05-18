class AddPromoterIdToSpreePromotions < ActiveRecord::Migration
  def change
    add_column :spree_promotions, :promoter_id, :integer
    add_index :spree_promotions, :promoter_id
  end
end
