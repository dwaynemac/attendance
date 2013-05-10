class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.references :account, index: true
      t.references :time_slot, index: true
      t.date :attendance_on

      t.timestamps
    end
  end
end
