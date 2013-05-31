class AttendanceContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :attendance
end