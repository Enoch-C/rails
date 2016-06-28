Spree::Sample.load_sample("cczones")
Spree::Sample.load_sample("cctax_categories")

usa = Spree::Zone.find_by_name!("USA")
global = Spree::Zone.find_by_name!("Global")
china = Spree::Zone.find_by_name!("China")

shipping_category_usa = Spree::ShippingCategory.find_or_create_by!(name: 'USA')
shipping_category_china = Spree::ShippingCategory.find_or_create_by!(name: 'China')
shipping_category_global = Spree::ShippingCategory.find_or_create_by!(name: 'Global')

tax_category = Spree::TaxCategory.find_by_name!("USA")

unless Spree::ShippingMethod.find_by_name("USPS") &&
  Spree::ShippingMethod.find_by_name("International Shipping") &&
  Spree::ShippingMethod.find_by_name("Shipping to China")
  Spree::ShippingMethod.create!([
    {
      :name => "USPS",
      :zones => [usa],
      :calculator => Spree::Calculator::Shipping::PriceSack.create!,
      :shipping_categories => [shipping_category_usa, shipping_category_global],
      :tracking_url => "https://tools.usps.com/go/TrackConfirmAction_input?qtc_tLabels1=:tracking",
      :tax_category_id => tax_category.id
    },
    {
      :name => "International Shipping",
      :zones => [global],
      :calculator => Spree::Calculator::Shipping::FlatRate.create!,
      :shipping_categories => [shipping_category_global],
      :tax_category_id => tax_category.id
    },
    {
      :name => "Shipping to China",
      :zones => [china],
      :calculator => Spree::Calculator::Shipping::FlatRate.create!,
      :shipping_categories => [shipping_category_global],
      :tax_category_id => tax_category.id
    }
  ])

  {
    "USPS" => [0, "USD"],
    "International Shipping" => [17, "USD"],
    "Shipping to China" => [10, "USD"]
  }.each do |shipping_method_name, (price, currency)|
    shipping_method = Spree::ShippingMethod.find_by_name!(shipping_method_name)
    shipping_method.calculator.preferences = {
      amount: price,
      currency: currency
    }
    shipping_method.calculator.save!
    shipping_method.save!
  end

  shipping_method = Spree::ShippingMethod.find_by_name!("USPS")
  shipping_method.calculator.preferences = {
    minimal_amount: 0.01,
    normal_amount: 3.99,
    discount_amount: 0.00,
    currency: "USD"
  }
  shipping_method.calculator.save!
  shipping_method.save!

end
