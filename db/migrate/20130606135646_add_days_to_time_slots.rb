class AddDaysToTimeSlots < ActiveRecord::Migration
  def change
    add_column :time_slots, :monday, :boolean
    add_column :time_slots, :tuesday, :boolean
    add_column :time_slots, :wednesday, :boolean
    add_column :time_slots, :thursday, :boolean
    add_column :time_slots, :friday, :boolean
    add_column :time_slots, :saturday, :boolean
    add_column :time_slots, :sunday, :boolean
  end
end
