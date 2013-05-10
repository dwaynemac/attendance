# This support package contains modules for authenticaiting
# devise users for request specs.

# This module authenticates users for request specs.#
module ValidUserRequestHelper
    # Define a method which signs in as a valid user.
    def sign_in_as_a_valid_user
        # ASk factory girl to generate a valid user for us.
        @user = build(:user)
		User.any_instance.stub(:padma_user).and_return(PadmaUser.new(:username => @user.username, :email => "test@test.com"))
		Account.any_instance.stub(:padma).and_return(PadmaAccount.new(:name => @user.current_account.name))
		User.any_instance.stub(:enabled_accounts).and_return([PadmaAccount.new(:name => @user.current_account.name)])
		@user.save

        # We action the login request using the parameters before we begin.
        # The login requests will match these to the user we just created in the factory, and authenticate us.
        post_via_redirect user_session_path, 'user[username]' => @user.username
    end
end

# Configure these to modules as helpers in the appropriate tests.
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include ValidUserRequestHelper, :type => :request
end