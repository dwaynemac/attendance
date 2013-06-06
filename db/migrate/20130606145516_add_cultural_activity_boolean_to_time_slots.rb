class AddCulturalActivityBooleanToTimeSlots < ActiveRecord::Migration
  def change
    add_column :time_slots, :cultural_activity, :boolean
  end
end
