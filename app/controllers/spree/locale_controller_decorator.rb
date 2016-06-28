module Spree
  Spree::LocaleController.class_eval do
    def set
      # unless params[:switch_to_locale].start_with('en')
      #   cookies["cc-locale"] = 'params[:switch_to_locale]'
      # end
      redirect_to root_path(locale: params[:switch_to_locale])
    end
  end
end
