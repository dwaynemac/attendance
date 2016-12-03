class SuspendedLessons < ActiveRecord::Migration
  def change
    add_column :attendances, :suspended, :boolean
  end
end
