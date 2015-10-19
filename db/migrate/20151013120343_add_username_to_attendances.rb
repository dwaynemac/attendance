class AddUsernameToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :username, :string
  end
end
