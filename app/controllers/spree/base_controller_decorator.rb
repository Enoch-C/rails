module Spree
  Spree::BaseController.class_eval do
    before_filter :set_locale

    private
      def set_locale
        return if cookies["cc-locale"]
        puts I18n.available_locales
        puts http_accept_language.preferred_language_from(I18n.available_locales)
        I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales)
        puts "* Locale set to '#{I18n.locale}'"

      end

  end
end
