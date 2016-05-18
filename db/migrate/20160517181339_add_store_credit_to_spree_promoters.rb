class AddStoreCreditToSpreePromoters < ActiveRecord::Migration
  def change
    add_column :spree_promoters, :store_credit, :decimal, precision: 8, scale: 2, default: 0.0, null: false
  end
end
