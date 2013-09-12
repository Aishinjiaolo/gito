class RenameSheetConetentToPath < ActiveRecord::Migration
  def change
    rename_column :sheets, :content, :path
    change_column :sheets, :path, :string
  end
end
