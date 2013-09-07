class CreateSpreadsheets < ActiveRecord::Migration
  def change
    create_table :spreadsheets do |t|
      t.text :content
      t.integer :user_id

      t.timestamps
    end
  end
end
