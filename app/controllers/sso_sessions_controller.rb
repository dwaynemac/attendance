class SsoSessionsController < ApplicationController

  skip_before_filter :get_sso_session, except: [:show]

  skip_before_filter :secret_key_login
  skip_before_filter :authenticate_user! # dont check for Devise Session
  skip_before_filter :require_padma_account
  skip_before_filter :set_current_account
  skip_before_filter :set_timezone
  skip_before_filter :set_locale

  def show
    # get_sso_session
  end

  # GET sso_sessions/new
  # quivalent to POST sso_sessions
  #
  # reads params:
  #   sso_token , will validate this with PADMA's SSO to start session
  #   destination , after signin will redirect to this url
  def new
    create
  end

  def create
    st = SsoToken.find params[:sso_token]
    if st && !st.account_name.blank? && !st.username.blank?

      # user and account are created if not found
      a = Account.find_or_create_by_name(st.account_name)
      user = User.find_or_create_by_username(st.username, :current_account_id => a)

      sign_in(user)

      if params[:destination].blank?
        redirect_to root_url
      else
        redirect_to params[:destination]
      end
    else
      render text: "got invalid token #{params[:sso_token]}"
    end
  end

  def destroy
    sign_out
    redirect_to padma_sso_logout_url
  end
end
