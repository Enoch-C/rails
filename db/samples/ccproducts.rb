tax_category = Spree::TaxCategory.find_by_name!("USA")
shipping_category_usa = Spree::ShippingCategory.find_by_name!("USA")
shipping_category_global = Spree::ShippingCategory.find_by_name!("Global")

default_attrs = {
  tax_category: tax_category,
  available_on: Time.zone.now
}

products = [
  {
    :name => Rails.application.config.product_list[0],
    :shipping_category => shipping_category_usa,
    :price => 0.00,
    :sku => "ccsd0000"
  },
  {
    :name => Rails.application.config.product_list[1],
    :shipping_category => shipping_category_usa,
    :price => 13.99,
    :sku => "ccsw0000"
  },
  {
    :name => Rails.application.config.product_list[2],
    :shipping_category => shipping_category_global,
    :price => 39.99,
    :sku => "ccsm0000"
  }
]

products.each do |product_attrs|
  Spree::Config[:currency] = "USD"
  unless Spree::Product.find_by_name(product_attrs[:name])
    product = Spree::Product.create!(default_attrs.merge(product_attrs))
  end
end
