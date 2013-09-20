class Sheet < ActiveRecord::Base
  belongs_to :user
  mount_uploader :sheetdata, SheetdataUploader

  attr_accessor :commit
end
