class ApplicationController < ActionController::Base

  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :secret_key_login
  before_filter :mock_login
  
  before_filter :authenticate_user!
  
  before_filter :require_padma_account
  before_filter :set_current_account
  before_filter :set_timezone
  before_filter :set_locale

  before_filter :tag_request_on_appsignal

  private

  def set_locale
    if signed_in?
      I18n.locale = current_user.locale
    end
    if params[:locale]
      I18n.locale = params[:locale]
    end
  end

  def secret_key_login
    unless signed_in?
      unless params[:secret_key_login].blank?
        key = params[:secret_key_login]
        apikey = Rails.cache.fetch("apikey#{key}", expires_in: 10.minutes) do
          ApiKey.find key
        end
        if apikey.access == 'login_key'

          a = Account.find_by_name(apikey.account_name)
          @session_current_account = a

          user = nil
          if apikey.username
            user = User.find_by_username(apikey.username)
          end
          if user.nil?
            user = User.find_by_username(a.usernames.first)
          end
          sign_in(user)
        end
      end
    end
  end

  # Mocks CAS login in development
  def mock_login
    if Rails.env.development?
      a = Account.find_or_create_by(name: "development")
      user = User.find_or_create_by(username: "luis.perichon", current_account_id: a.id)

      sign_in(user)
    end
  end

  # CAS user must have a PADMA account
  def require_padma_account
    if signed_in?
      unless current_user.padma_enabled?
        render text: 'Access allowed to PADMA users only - Think this is a mistake? Maybe PADMA Authentication service is down.'
      end
    end
  end

  def set_current_account
    if signed_in? && current_user.padma_enabled?
      current_user.current_account = Account.find_or_create_by(name: current_user.padma.current_account_name)
    end
  end

  def current_account
    current_user.current_account
  end  

  def set_timezone
    if signed_in? && current_user.padma_enabled?
      Time.zone = current_user.current_account.padma.timezone
    end
  end

  def tag_request_on_appsignal
    if signed_in?
      Appsignal.tag_request(
        intercom_user_id: current_user.username
      )
    end
  end
end
