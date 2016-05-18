class CreateSpreePromoters < ActiveRecord::Migration
  def change
    create_table :spree_promoters do |t|
      t.string   :secret
      t.string   :email
      t.string   :phone
      t.integer  :percent, default: 15
      t.string   :first_name
      t.string   :last_name
      t.timestamps null: false
    end
  end
end
