Spree::Sample.load_sample("ccoption_types")

["func1", "func2", "func3"].each do |func_name|
  Rails.application.config.function_list.each_with_index do |name, index|
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
