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

  # @param [CSV::Row] row
  # @param [String] attribute_name
  def value_for(row,attribute_name)
    row[index_for(attribute_name)]
  end

  # overrride this method on child class
  def valid_headers
  end

  # Override this on child class
  # @param [CSV::Row]
  # @return [Integer/Nil] will return id for imported_rows or nil if it failed
  def handle_row(row)
  end

  def process_CSV
    return unless self.status == :ready

    file_handle = open(self.csv_file.file.path)
    unless file_handle.nil?
      row_i = 1 # start at 1 because first row is skipped
      CSV.foreach(file_handle, encoding:"UTF-8:UTF-8", headers: :first_row) do |row|
        if iid = handle_row(row)
          self.imported_ids << iid
        else
          self.failed_rows << row_i
        end
        row_i += 1
      end
    end

    self.status = :finished
    self.save
  end
  
  # @return [Contact]
  def map_contact(external_id)
    c = PadmaContact.find_by_kshema_id(external_id)
    Contact.get_by_padma_id(c.id,self.account.id, c) if c
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
