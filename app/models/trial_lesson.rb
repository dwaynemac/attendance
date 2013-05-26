class TrialLesson < ActiveRecord::Base
  belongs_to :account
  belongs_to :contact
  belongs_to :time_slot

  validates :account_id, presence: true
  validates :contact_id, presence: true
  validates :time_slot_id, presence: true
  validates :padma_uid, presence: true
  validates :trial_on, presence: true
  validates_date :trial_on, on_or_after: :today
end
