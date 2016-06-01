Spree::Sample.load_sample("ccoption_values")
Spree::Sample.load_sample("ccproducts")

func1_id = Spree::OptionType.find_by_name!("func1").id
func2_id = Spree::OptionType.find_by_name!("func2").id
func3_id = Spree::OptionType.find_by_name!("func3").id

tax_category = Spree::TaxCategory.find_by_name!("USA")

Rails.application.config.product_list.each_with_index do |product_name, product_index|
  Rails.application.config.function_list.combination(3).each_with_index do |funcs, index|
    cost_price = 0
    sku = ""
    case product_index
    when 0
      cost_price = 3.99
      sku = "ccsd"
    when 1
      cost_price = 13.99
      sku = "ccsw"
    when 2
      cost_price = 39.99
      sku = "ccsm"
    end
    sku = sku + format('%04d', index + 1)
    unless Spree::Variant.find_by(sku: sku)
      Spree::Variant.create!(
      {
        :product => Spree::Product.find_by_name!(product_name),
        :option_values => [Spree::OptionValue.find_by_name_and_option_type_id!(funcs[0], func1_id), Spree::OptionValue.find_by_name_and_option_type_id!(funcs[1], func2_id), Spree::OptionValue.find_by_name_and_option_type_id!(funcs[2], func3_id)],
        :sku => sku,
        :cost_price => cost_price,
        :tax_category => tax_category
      })
    end
  end
end

# masters.each do |product, variant_attrs|
#   product.master.update_attributes!(variant_attrs)
# end
