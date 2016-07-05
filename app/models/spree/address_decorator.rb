module Spree
  Spree::Address.class_eval do
    def state_text
      state.try(:name) || state_name
    end
  end
end
