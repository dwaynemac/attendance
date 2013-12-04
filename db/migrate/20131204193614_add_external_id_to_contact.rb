class AddExternalIdToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :external_sysname, :string
    add_column :contacts, :external_id, :string
  end
end
