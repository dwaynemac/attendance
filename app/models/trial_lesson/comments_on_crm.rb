require 'padma_crm_api'
module TrialLesson::CommentsOnCRM
  extend ActiveSupport::Concern

  included do

    attr_accessor :activity_on_trial_time

    after_create :create_comment
    after_destroy :destroy_comment

    def crm_reference
      "attendance-trial_lesson-#{id}"
    end

    def inform_crm(action, locale, assisted = true)
      case action
        when :create
          assistance_create_comment(assisted, locale)
        when :update
          assistance_update_comment(assisted, locale)
        when :destroy
          assistance_destroy_comment(locale)
      end
    end

    def assistance_create_comment(assisted, locale = nil)
      I18n.locale = locale unless locale.nil?
      unless contact_id.nil?
        crm_api.create_comment(
          external_reference: crm_reference,
          username: padma_uid,
          account_name: account.name,
          contact_id: contact.padma_id,
          observations: I18n.t("trial_lesson.activity_content.assisted.#{assisted}"),
          commented_at: trial_at,
          public: false
        )
      end
    end
    handle_asynchronously :assistance_create_comment

    def crm_comments(where = {})
      @crm_comments ||= crm_api.paginate_comments(where.merge({external_reference: crm_reference}))
    end

    def assistance_update_comment(assisted, locale = nil)
      I18n.locale = locale unless locale.nil?
      crm_comments(observations: I18n.t("trial_lesson.activity_content.assisted.#{!assisted}")).each do |comment|
        res = crm_api.update_comment(comment["id"], observations: I18n.t("trial_lesson.activity_content.assisted.#{assisted}"))
        if res.nil?
          Rails.logger.warn "couldnt update comment #{comment["id"]} for trial lesson #{self.id}"
        end
      end
    end
    handle_asynchronously :assistance_update_comment

    def assistance_destroy_comment(locale = nil)
      I18n.locale = locale unless locale.nil?
      crm_comments.each do |comment|
        if comment["observations"] == I18n.t("trial_lesson.activity_content.assisted.true") ||
          comment["observations"] == I18n.t("trial_lesson.activity_content.assisted.false")
          res = crm_api.destroy_comment(comment["id"])
          if res.nil?
            Rails.logger.warn "couldnt destroy comment #{comment["id"]} for trial lesson #{self.id}"
          end
        end
      end
    end
    handle_asynchronously :assistance_destroy_comment

    def create_comment
      # Send notification to activities
      unless contact_id.nil?
        created_at = (self.activity_on_trial_time) ? self.trial_at.to_s : Time.zone.now.to_s

        crm_api.create_comment(
          external_reference: crm_reference,
          username: padma_uid,
          account_name: account.name,
          contact_id: contact.padma_id,
          observations: I18n.t('trial_lesson.activity_content.create'),
          commented_at: created_at,
          public: false
        )
      end
    end

    def destroy_comment
      # Send notification to activities
      unless contact_id.nil?
        crm_api.create_comment(
          external_reference: crm_reference,
          username: padma_uid,
          account_name: account.name,
          contact_id: contact.padma_id,
          observations: I18n.t('trial_lesson.activity_content.deleted'),
          commented_at: Time.zone.now,
          public: false
        )
      end
    end

    def crm_api
      @crm_api ||= PadmaCrmApi.new
    end
  end
end
