class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :type

      t.references :account

      t.string :status
                                  
      t.text :failed_rows, limit:  1073741824 # LONGTEXT (max 1Gb)
      t.text :imported_ids, limit: 1073741824 # LONGTEXT (max 1Gb)

      t.timestamps
    end
  end
end
