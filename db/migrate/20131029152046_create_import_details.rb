class CreateImportDetails < ActiveRecord::Migration
  def change
    create_table :import_details do |t|
      t.integer :value
      t.integer :import_id
      t.string :type

      t.timestamps
    end
  end
end
