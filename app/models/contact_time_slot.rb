class ContactTimeSlot < ActiveRecord::Base
  belongs_to :time_slot
  belongs_to :contact

  # attr_accessible :time_slot_id
  # attr_accessible :contact_id

  validates_presence_of :time_slot_id
  validates_presence_of :contact_id

  validates_uniqueness_of :contact_id, scope: :time_slot_id
end
