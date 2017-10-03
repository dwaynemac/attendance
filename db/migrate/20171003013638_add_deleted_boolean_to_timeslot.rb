class AddDeletedBooleanToTimeslot < ActiveRecord::Migration
  def change
    add_column :time_slots, :deleted, :boolean
  end
end
