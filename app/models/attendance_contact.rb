class AttendanceContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :attendance

  attr_accessible :contact_id, :attendance_id
end
