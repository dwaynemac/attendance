class Import < ActiveRecord::Base

  attr_accessible :headers, :csv_file

  belongs_to :account

  serialize :failed_rows, Array
  serialize :headers, Array
  serialize :imported_ids, Array

  VALID_STATUS = [:ready, :working, :finished]

  before_create :set_defaults
  validate :validate_headers

  mount_uploader :csv_file, CsvUploader

  # Sets account by name
  # @param [String] name
  def account_name=(name)
    self.account = Account.find_by_name(name)
  end
  
  # It returns column number for given attribute according to headers
  # @param [String] attribute_name
  def index_for(attribute_name)
    self.headers.index(attribute_name)
  end

  # overrride this method on child class
  def valid_headers
  end

  private

  def set_defaults
    if self.status.nil?
      self.status = :ready
    end
    if self.imported_ids.nil?
      self.imported_ids = []
    end
    if self.failed_rows.nil?
      self.failed_rows = []
    end
  end

  def validate_headers
    if self.headers.nil? || self.headers.empty?
      return
    elsif self.valid_headers.nil?
      errors.add(:headers, 'invalid headers - check import type, there are no valid headers')
    else
      # compat headers, this way we consider nil valid
      unless (self.headers.compact - self.valid_headers).empty?
        errors.add(:headers, 'invalid headers')
      end
    end
  end

end
