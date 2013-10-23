class ImportHasCsvFile < ActiveRecord::Migration
  def change
    add_column :imports, :csv_file, :string
  end
end
