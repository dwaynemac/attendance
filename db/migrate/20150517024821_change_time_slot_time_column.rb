class ChangeTimeSlotTimeColumn < ActiveRecord::Migration
  def change
    change_column :time_slots, :start_at, :time
    change_column :time_slots, :end_at, :time
  end
end
