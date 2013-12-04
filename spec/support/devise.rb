# This support package contains modules for authenticaiting
# devise users for request specs.

# This module authenticates users for request specs.#
module ValidUserRequestHelper

    # Define a method which signs in as a valid user.
    def sign_in_as_a_valid_user
      cur_acc = create(:account)
      @user = build(:user, current_account: cur_acc)
      User.any_instance.stub(:padma_user).and_return(PadmaUser.new(:username => @user.username, :email => "test@test.com", current_account_name: cur_acc.name))
      Account.any_instance.stub(:padma).and_return(PadmaAccount.new(:name => @user.current_account.name))
      User.any_instance.stub(:enabled_accounts).and_return([PadmaAccount.new(:name => @user.current_account.name)])
      @user.save!
      @user.reload.current_account.should_not be_nil
      sign_in @user
      @user
    end
end

# Configure these to modules as helpers in the appropriate tests.
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include ValidUserRequestHelper, :type => :controller
end
