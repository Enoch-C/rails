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

    def options_text_cn
      cn = {
      "Anti-Aging": "延缓衰老",
      "Beauty": "美容养颜",
      "Brain Care": "益智健脑",
      "Digestive Care": "肠道健康",
      "Energy": "补充能量",
      "Eye Care": "保护视力",
      "Heart Care": "心血管健康",
      "Immune Care": "增强免疫",
      "Joint Care": "关节保护",
      "Liver Care": "排毒护肝",
      "Lung Care": "清肺养肺",
      "Men's Vitality": "男性活力",
      "Sleep Support": "改善睡眠",
      "Stress Relief": "舒缓压力"
    }
      values = self.option_values.sort do |a, b|
        a.option_type.position <=> b.option_type.position
      end

      values.to_a.map! do |ov|
        cn[:"#{ov.presentation}"]
      end

      values.to_sentence({ words_connector: " + ", two_words_connector: " + ", last_word_connector: " + " })
    end
  end
end
