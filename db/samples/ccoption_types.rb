unless Spree::OptionType.find_by_name("func1") &&
  Spree::OptionType.find_by_name("func2") &&
  Spree::OptionType.find_by_name("func3")
  Spree::OptionType.create!([
    {
      :name => "func1",
      :presentation => "Choice A",
      :position => 1
    },
    {
      :name => "func2",
      :presentation => "Choice B",
      :position => 2
    },
    {
      :name => "func3",
      :presentation => "Choice C",
      :position => 3
    }
  ])
end
