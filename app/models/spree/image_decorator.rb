module Spree
  Spree::Image.class_eval do
    attachment_definitions[:attachment][:styles] = {
      mini:     "96x96>",
      small:    "290x290>",
      product:  "480x480>",
      large:    "1200x1200>"
    }
  end
end
