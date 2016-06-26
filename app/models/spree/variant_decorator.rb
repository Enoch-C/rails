module Spree
  Spree::Variant.class_eval do
    def options_text
      values = self.option_values.sort do |a, b|
        a.option_type.position <=> b.option_type.position
      end

      values.to_a.map! do |ov|
        "#{ov.presentation}"
      end

      values.to_sentence({ words_connector: " + ", two_words_connector: " + ", last_word_connector: " + " })
    end
  end
end
