class Import < ActiveRecord::Base

  # attr_accessible :failed_rows, :headers, :imported_rows, :status, :account_name

  belongs_to :account

  serialize :failed_rows, Array
  serialize :headers, Array
  serialize :imported_rows, Array

  before_save :default_status

  mount_uploader :csv_file, CsvUploader

  # Sets account by name
  # @param [String] name
  def account_name=(name)
    self.account = Account.find_or_create_by_name(name)
  end

  private

  def default_status
    if self.status.nil?
      self.status = 'ready'
    end
  end

end
