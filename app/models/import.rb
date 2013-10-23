class Import < ActiveRecord::Base

  belongs_to :account

  attr_accessible :failed_rows, :headers, :imported_rows, :status, :account_name
  serialize :failed_rows, Array
  serialize :headers, Array
  serialize :imported_rows, Array

  before_save :default_status


  private

  def default_status
    if self.status.nil?
      self.status = 'ready'
    end
  end

end
