class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.references :account, index: true
      t.string :padma_id

      t.timestamps
    end
  end
end
