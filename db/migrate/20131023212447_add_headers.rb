class AddHeaders < ActiveRecord::Migration
  def change
    add_column :imports, :headers, :text, limit: 4294967295 # LONGTEXT (max 4Gb)
  end
end
