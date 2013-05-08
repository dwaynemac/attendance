class TimeSlot < ActiveRecord::Base
  belongs_to :account
  validates :account,  :presence => true
  validates :name,  :presence => true
  validates_time :end_at, :after => :start_at
end
