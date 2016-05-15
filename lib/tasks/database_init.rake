namespace :database_init do
  desc "create a global_zone except US and CN"
  task global_zone: :environment do
    global_zone = Spree::Zone.find_or_initialize_by(name:'Global') do |z|
      excluded_countries = %w[US CN]
      member_list = Spree::Country.where('iso not in (?)', excluded_countries)
      puts "Creating Global Zone With Members: #{member_list.map(&:iso)}"
      member_list.each do |member|
        z.zone_members.build :zoneable_type => 'Spree::Country', :zoneable_id => member.id
      end
      z.description = "Global(US and CN excluded)"
      z.save!
    end
  end

end
