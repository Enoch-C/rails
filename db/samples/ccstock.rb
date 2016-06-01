Spree::Sample.load_sample("ccvariants")

country =  Spree::Country.find_by(iso: 'US')
state =  Spree::Country::State.find_by_name('California')
location = Spree::StockLocation.first_or_create! name: 'Cool Choice, California, USA', address1: '1376 E. Valencia Drive', city: 'Fullerton', zipcode: '92831', country: country, state: state
location.name = 'Cool Choice, California, USA'
location.address1 = '1376 E. Valencia Drive'
location.city = 'Fullerton'
location.zipcode = '92831'
location.state = state
location.country = country
location.active = true
location.save!

Spree::Variant.all.each do |variant|
  variant.stock_items.each do |stock_item|
    Spree::StockMovement.create(:quantity => 10, :stock_item => stock_item)
  end
end
