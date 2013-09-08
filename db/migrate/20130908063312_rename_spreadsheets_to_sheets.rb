class RenameSpreadsheetsToSheets < ActiveRecord::Migration
  def change
    rename_table :spreadsheets, :sheets
  end
end
