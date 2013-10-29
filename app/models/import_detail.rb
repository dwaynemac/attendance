class ImportDetail < ActiveRecord::Base
  attr_accessible :value
  belongs_to :import, autosave: true, dependent: :destroy
  validates_presence_of :value
end
