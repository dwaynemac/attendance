class AddUnscheduledBooleanToTimeslots < ActiveRecord::Migration
  def change
    add_column :time_slots, :unscheduled, :boolean
  end
end
