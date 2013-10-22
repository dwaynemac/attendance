class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :type

      t.references :account

      t.string :status

      t.text :failed_rows, limit: 4294967295 # LONGTEXT (max 4Gb)
      t.text :imported_ids, limit: 4294967295 # LONGTEXT (max 4Gb)

      t.timestamps
    end
  end
end
