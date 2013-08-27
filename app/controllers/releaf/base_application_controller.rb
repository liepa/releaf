module Releaf
  class BaseApplicationController < ActionController::Base
    before_filter "authenticate_#{ReleafDeviseHelper.devise_admin_model_name}!"
    before_filter :set_locale

    rescue_from Releaf::AccessDenied, with: :access_denied
    rescue_from Releaf::FeatureDisabled, with: :feature_disabled

    layout Releaf.layout
    protect_from_forgery

    helper_method :controller_scope_name

    # return contoller translation scope name for using
    # with I18.translation call within hash params
    # ex. t("save", scope: controller_scope_name)
    def controller_scope_name
      'admin.' + self.class.name.sub(/Controller$/, '').underscore.gsub('/', '_')
    end

    # set locale for interface translating from current admin user
    def set_locale
      admin = send("current_" + ReleafDeviseHelper.devise_admin_model_name)
      I18n.locale = admin.locale
      Releaf::Globalize3::Fallbacks.set
    end

    def feature_disabled exception
      @feature = exception.message
      respond_to do |format|
        format.html { render 'releaf/error_pages/feature_disabled', status: 403 }
        format.any  { render text: '', status: 403 }
      end
    end

    def access_denied
      @controller_name = self.class.name.sub(/Controller$/, '').underscore
      respond_to do |format|
        format.html { render 'releaf/error_pages/access_denied', status: 403 }
        format.any  { render text: '', status: 403 }
      end
    end

    def page_not_found
      respond_to do |format|
        format.html { render 'releaf/error_pages/page_not_found', status: 404 }
        format.any  { render text: '', status: 404 }
      end
    end
  end
end
