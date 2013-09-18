class RenameSheetPathToName < ActiveRecord::Migration
  def change
    rename_column :sheets, :path, :name
  end
end
