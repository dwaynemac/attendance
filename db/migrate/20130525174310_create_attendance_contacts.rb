class CreateAttendanceContacts < ActiveRecord::Migration
  def change
    create_table :attendance_contacts do |t|
    	t.references :attendance, index: true
    	t.references :contact, index: true
    end
  end
end
