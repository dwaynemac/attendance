class Attendance < ActiveRecord::Base
  belongs_to :account
  belongs_to :time_slot

  validates :account, :presence => true
  validates :time_slot, :presence => true
  validates :attendance_on, :presence => true
  validates_date :attendance_on, :on_or_before => :today
end
