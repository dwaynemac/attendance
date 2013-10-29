class RemoveSerializedColumns < ActiveRecord::Migration
  def change
    remove_column :imports, :imported_ids
    remove_column :imports, :failed_rows
  end
end
