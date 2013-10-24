class AddTimeSlotObervations < ActiveRecord::Migration
  def change
    add_column :time_slots, :observations, :text
  end
end
