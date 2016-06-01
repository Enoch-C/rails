china = Spree::Zone.find_by_name!("China")
global = Spree::Zone.find_by_name!("Global")
usa = Spree::Zone.find_by_name!("USA")
ca = Spree::Zone.find_by_name!("CA")
tax_category = Spree::TaxCategory.find_by_name!("USA")

unless Spree::TaxRate.find_by_name("Sales Tax")
  tax_rate = Spree::TaxRate.create(
    :name => "Sales Tax",
    :zone => china,
    :amount => 0.0,
    :show_rate_in_label => false,
    :tax_category => tax_category)
  tax_rate.calculator = Spree::Calculator::DefaultTax.create!
  tax_rate.save!
  tax_rate = Spree::TaxRate.create(
    :name => "Sales Tax",
    :zone => global,
    :amount => 0.0,
    :show_rate_in_label => false,
    :tax_category => tax_category)
  tax_rate.calculator = Spree::Calculator::DefaultTax.create!
  tax_rate.save!
  tax_rate = Spree::TaxRate.create(
    :name => "Sales Tax",
    :zone => usa,
    :amount => 0.0,
    :show_rate_in_label => false,
    :tax_category => tax_category)
  tax_rate.calculator = Spree::Calculator::DefaultTax.create!
  tax_rate.save!
  tax_rate = Spree::TaxRate.create(
    :name => "Sales Tax",
    :zone => ca,
    :amount => 0.0,
    :show_rate_in_label => false,
    :tax_category => tax_category)
  tax_rate.calculator = Spree::Calculator::TaxCloudCalculator.create!
  tax_rate.save!
end
