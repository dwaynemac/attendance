class MessageDoorController < ApplicationController
  include SnsHelper
  include SsoSessionsHelper

  skip_before_filter :verify_authenticity_token

  skip_before_filter :get_sso_session

  skip_before_filter :mock_login
  skip_before_filter :authenticate_user!
  skip_before_filter :require_padma_account
  skip_before_filter :set_current_account

  def sns
    case sns_type
    when 'SubscriptionConfirmation'
      # confirm subscription to Topic
      render json: Typhoeus.get(sns_data[:SubscribeURL]).body, status: 200
    when 'Notification'
      if sns_verified?
        if sns_duplicate_submission?
          render json: 'duplicate', status: 200
        else

          case sns_topic
          when "sso_session_destroyed"
            set_sso_session_destroyed_flag(sns_message[:username])
            when "updated_contact", "created_contact"
            if sns_message[:id]
              Delayed::Job.enqueue FetchCrmContactJob.new(id: sns_message[:id],
                account_name: sns_message[:account_name])
            end
          else
            # ignore, do nothing
          end
          
          sns_set_as_received!
          render json: "received", status: 200
        end
      else
        render json: 'unverified', status: 403
      end
    else
      render json: 'WTF', status: 400
    end
  end

end
