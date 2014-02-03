class RemoteTimeSlotId < ActiveRecord::Migration
  def change
    remove_column :contacts, :time_slot_id
  end
end
