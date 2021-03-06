class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end

    # user can do everything on templates of his account.

    self.merge GeneralAbility.new(user)

    if alpha?(user)
      # alpha only
    end

    if beta?(user)
      # beta only
    end
    
    can :include_former_students, :stats
    can :manage, TimeSlot, account_id: user.current_account_id
    can :manage, Attendance, account_id: user.current_account_id
    can :manage, AttendanceContact, attendance: { account_id: user.current_account_id }
    can :manage, TrialLesson, account_id: user.current_account_id
    can :manage, Contact do |c|
      c.accounts.where(:id => user.current_account_id)
    end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end

  private

  def alpha?(user)
    user.current_account.padma.try(:tester_level) == 'alpha'
  end

  def beta?(user)
    tl = user.current_account.padma.try(:tester_level)
    tl == 'alpha' || tl == 'beta'
  end

end
