class AttendanceContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :attendance, inverse_of: :attendance_contacts

  attr_accessible :contact_id, :attendance_id

  validates :contact, presence: true
  validates :attendance, presence: true
end
