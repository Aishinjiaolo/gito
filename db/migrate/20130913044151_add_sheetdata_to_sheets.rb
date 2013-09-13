class AddSheetdataToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :sheetdata, :string
  end
end
