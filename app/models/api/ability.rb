class Api::Ability
  include CanCan::Ability

  def initialize(app_key,account_name=nil)
    cannot(:manage, :all)
    if Api::V0::ApiController.valid_app_key?(app_key)
      can(:manage,:all)
    end
  end
                 
end
