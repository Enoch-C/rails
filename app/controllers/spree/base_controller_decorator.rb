module Spree
  Spree::BaseController.class_eval do
    before_filter :set_locale

    private
      def set_locale
        # return if cookies["cc-locale"]
        # accept_langs = env["HTTP_ACCEPT_LANGUAGE"]
        # return if accept_langs.nil?
        # languages_and_qvalues = accept_langs.split(",").map { |l|
        #   l += ';q=1.0' unless l =~ /;q=\d+(?:\.\d+)?$/
        #   l.split(';q=')
        # }
        # lang = languages_and_qvalues.sort_by { |(locale, qvalue)|
        #   qvalue.to_f
        # }
        # lang = lang.last.first
        # if lang.start_with?('en')
        #   cookies["cc-locale"] = 'en-US'
        # else
        #   cookies["cc-locale"] = 'others'
        #   redirect_to spree.localization_path
        # end
      end

  end
end
