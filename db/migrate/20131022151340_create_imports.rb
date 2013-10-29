class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :type

      t.references :account

      t.string :status
                                  
      t.text :failed_rows
      t.text :imported_ids

      t.timestamps
    end
  end
end
