module Spree
  Spree::Address.class_eval do
    def state_text
      if this.country.name.start_with?("United States") || this.country.name.start_with?("Canada")
        state.try(:abbr) || state.try(:name) || state_name
      else
        state.try(:name) || state_name
      end
    end
  end
end
