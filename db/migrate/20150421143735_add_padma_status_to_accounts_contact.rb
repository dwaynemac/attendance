class AddPadmaStatusToAccountsContact < ActiveRecord::Migration
  def change
    add_column :accounts_contacts, :padma_status, :string
  end
end
