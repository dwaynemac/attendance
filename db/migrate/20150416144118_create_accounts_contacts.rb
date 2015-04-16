class CreateAccountsContacts < ActiveRecord::Migration
  def change
    create_table :accounts_contacts, :id => false do |t|
      t.references :account
      t.references :contact
    end
  end
end
