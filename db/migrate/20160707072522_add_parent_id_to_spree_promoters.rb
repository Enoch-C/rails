class AddParentIdToSpreePromoters < ActiveRecord::Migration
  def change
    add_column :spree_promoters, :parent_id, :integer
    add_column :spree_promoters, :identity, :string
    add_column :spree_promoters, :payment, :string
    add_column :spree_promoters, :note, :text
    add_index  :spree_promoters, :parent_id
  end
end
