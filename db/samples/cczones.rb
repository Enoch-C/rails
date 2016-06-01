Spree::Zone.find_or_initialize_by(name:'Global') do |z|
  excluded_countries = %w[US CN]
  member_list = Spree::Country.where('iso not in (?)', excluded_countries)
  puts "Creating Global Zone With Members: #{member_list.map(&:iso)}"
  member_list.each do |member|
    z.zone_members.build :zoneable_type => 'Spree::Country', :zoneable_id => member.id
  end
  z.description = "Global(US and CN excluded)"
  z.save!
end

Spree::Zone.find_or_initialize_by(name:'USA') do |z|
  member = Spree::Country.find_by!(iso: 'US')
  z.zone_members.build :zoneable_type => 'Spree::Country', :zoneable_id => member.id
  z.save!
end

Spree::Zone.find_or_initialize_by(name:'China') do |z|
  member = Spree::Country.find_by!(iso: 'CN')
  z.zone_members.build :zoneable_type => 'Spree::Country', :zoneable_id => member.id
  z.save!
end

Spree::Zone.find_or_initialize_by(name:'CA') do |z|
  member = Spree::State.find_by!(name: 'California')
  z.zone_members.build :zoneable_type => 'Spree::State', :zoneable_id => member.id
  z.save!
end
