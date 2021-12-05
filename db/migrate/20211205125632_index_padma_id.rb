class IndexPadmaId < ActiveRecord::Migration
  def change
    add_index :contacts, :padma_id
  end
end
