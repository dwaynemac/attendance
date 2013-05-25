class AttendanceContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :attendance
  validates :contact, :presence => true
  validates :attendance, :presence => true
end