class AddSourceToAttendancesContacts < ActiveRecord::Migration
  def change
    add_column :attendance_contacts, :source, :string
  end
end
