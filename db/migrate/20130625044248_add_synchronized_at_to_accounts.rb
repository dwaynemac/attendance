class AddSynchronizedAtToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :synchronized_at, :datetime
  end
end
