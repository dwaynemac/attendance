class CreateTimeSlots < ActiveRecord::Migration
  def change
    create_table :time_slots do |t|
      t.string :padma_uid
      t.references :account
      t.string :name
      t.time :start_at
      t.time :end_at

      t.timestamps
    end
  end
end
