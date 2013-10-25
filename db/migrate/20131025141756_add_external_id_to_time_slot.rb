class AddExternalIdToTimeSlot < ActiveRecord::Migration
  def change
    add_column :time_slots, :external_id, :string
  end
end
