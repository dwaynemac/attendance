class AddMessageToImportDetail < ActiveRecord::Migration
  def change
    add_column :import_details, :message, :text
  end
end
