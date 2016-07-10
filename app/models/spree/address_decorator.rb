module Spree
  Spree::Address.class_eval do
    def state_text
      if self.country.name.start_with?("United States") || self.country.name.start_with?("Canada")
        state.try(:abbr) || state.try(:name) || state_name
      else
        state.try(:name) || state_name
      end
    end
  end
end
