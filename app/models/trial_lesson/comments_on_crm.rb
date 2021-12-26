module TrialLesson::CommentsOnCRM
  extend ActiveSupport::Concern

  included do

    attr_accessor :activity_on_trial_time

    after_create :create_activity
    after_destroy :destroy_activity

    def inform_activity_stream(action, locale, assisted = true)
      case action
        when :create
          assistance_create_activity(assisted, locale)
        when :update
          assistance_update_activity(assisted, locale)
        when :destroy
          assistance_destroy_activity(locale)
      end
    end

    def assistance_create_activity(assisted, locale = nil)
      I18n.locale = locale unless locale.nil?
      if !self.contact_id.nil?
        a = ActivityStream::Activity.new(target_id: self.contact.padma_id, target_type: 'Contact',
          object_id: self.id, object_type: 'TrialLesson',
          generator: ActivityStream::LOCAL_APP_NAME,
          content: I18n.t("trial_lesson.activity_content.assisted.#{assisted}"),
          public: false,
          username: self.padma_uid,
          account_name: self.account.name,
          created_at: self.trial_at.to_s,
          updated_at: self.trial_at.to_s )
        a.create(username: self.padma_uid, account_name: self.account.name)
      end
    end
    handle_asynchronously :assistance_create_activity

    def assistance_update_activity(assisted, locale = nil)
      I18n.locale = locale unless locale.nil?
      activities = ActivityStream::Activity.paginate(
        where: {
          object_id: self.id,
          object_type: 'TrialLesson',
          content: I18n.t("trial_lesson.activity_content.assisted.#{!assisted}")
        },
        per_page: 9999
      )
      activities.each do |activity|
        if activity.content == I18n.t("trial_lesson.activity_content.assisted.#{!assisted}")
          res = activity.update(
            'activity' => {
              content: I18n.t("trial_lesson.activity_content.assisted.#{assisted}")
            },
            account_name: self.account.name
          )
          if res.nil?
            Rails.logger.warn "couldnt update activity #{activity.id} for trial lesson #{self.id}"
          end
        end
      end
    end
    handle_asynchronously :assistance_update_activity

    def assistance_destroy_activity(locale = nil)
      I18n.locale = locale unless locale.nil?
      activities = ActivityStream::Activity.paginate(
        where: {
          object_id: self.id,
          object_type: 'TrialLesson'
        },
        per_page: 9999
      )
      activities.each do |activity|
        if activity.content == I18n.t("trial_lesson.activity_content.assisted.true") ||
          activity.content == I18n.t("trial_lesson.activity_content.assisted.false")
          res = activity.destroy(
            account_name: self.account.name
          )
          if res.nil?
            Rails.logger.warn "couldnt destroy activity #{activity.id} for trial lesson #{self.id}"
          end
        end
      end
    end
    handle_asynchronously :assistance_destroy_activity

    def create_activity
      # Send notification to activities
      if !self.contact_id.nil?

        created_at = (self.activity_on_trial_time)? self.trial_at.to_s : Time.zone.now.to_s
        updated_at = (self.activity_on_trial_time)? self.trial_at.to_s : Time.zone.now.to_s

        a = ActivityStream::Activity.new(target_id: self.contact.padma_id, target_type: 'Contact',
          object_id: self.id, object_type: 'TrialLesson',
          generator: ActivityStream::LOCAL_APP_NAME,
          content: I18n.t('trial_lesson.activity_content.create'),
          public: false,
          username: self.padma_uid,
          account_name: self.account.name,
          created_at: created_at,
          updated_at: updated_at )
        a.create(username: self.padma_uid, account_name: self.account.name)
      end
    end

    def destroy_activity
      # Send notification to activities
      if !self.contact_id.nil?
        a = ActivityStream::Activity.new(target_id: self.contact.padma_id, target_type: 'Contact',
          object_id: self.id, object_type: 'TrialLesson',
          generator: ActivityStream::LOCAL_APP_NAME,
          content: I18n.t('trial_lesson.activity_content.deleted'),
          verb: 'deleted',
          public: false,
          username: self.padma_uid,
          account_name: self.account.name,
          created_at: Time.zone.now.to_s,
          updated_at: Time.zone.now.to_s )
        a.create(username: self.padma_uid, account_name: self.account.name)
      end
    end
  end
end
