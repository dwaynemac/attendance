class Api::Ability
  include CanCan::Ability

  def initialize(app_key,account_name=nil)
    cannot(:manage, :all)
    unless app_key.blank?
      case app_key
      when Api::V0::ApiController::APP_KEY
        can(:manage,:all)
      end
    end
  end
                 
end
