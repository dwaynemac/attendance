class AddHeaders < ActiveRecord::Migration
  def change
    add_column :imports, :headers, :text
  end
end
