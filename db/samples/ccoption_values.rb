Spree::Sample.load_sample("ccoption_types")

["func1", "func2", "func3"].each do |func_name|
  ["Anti-Aging", "Beauty", "Brain Care", "Digestive Care", "Energy", "Eye Care", "Heart Care", "Immune Support", "Joint Care", "Liver Care", "Lung Care", "Men's Vitality", "Sleep Support", "Stress Management"].each_with_index do |name, index|
    type = Spree::OptionType.find_by_name!(func_name)
    unless Spree::OptionValue.find_by_name_and_option_type_id(name, type.id)
      Spree::OptionValue.create!(
        {
          :name => name,
          :presentation => name,
          :position => index,
          :option_type => type
        })
    end
  end
end
