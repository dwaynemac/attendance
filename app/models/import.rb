require 'open-uri'
require 'csv'

class Import < ActiveRecord::Base

  # attr_accessible :headers, :csv_file

  belongs_to :account
  validates_presence_of :account

  has_many :import_details
  has_many :imported_ids
  has_many :failed_rows

  serialize :headers, Array

  VALID_STATUS = [:ready, :working, :finished]

  before_create :set_defaults
  validate :validate_headers

  mount_uploader :csv_file, CsvUploader

  # Sets account by name
  # @param [String] name
  def account_name=(name)
    self.account = Account.find_or_create_by(name: name)
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

  # override this method on child class
  def post_import_tasks
  end

  # Override this on child class
  # @param [CSV::Row]
  # @param [Integer] row index
  # @return [ImportDetail] 
  def handle_row(row)
  end

  def process_CSV
    return unless self.status.to_sym == :ready
    
    begin
      log "processing csv"

      self.update_attribute(:status, :working)

      unless csv_file_handle.nil?
        row_i = 1 # start at 1 because first row is skipped
        CSV.foreach(csv_file_handle, encoding:"UTF-8:UTF-8", headers: :first_row) do |row|
          log "row #{row_i}"
          begin
            log "     ok"
            self.import_details << handle_row(row, row_i)
            self.import_details.last.save
          rescue => e
            log "     failed"
            self.import_details << FailedRow.new(value: row_i, message: "Exception: #{e.message}")
            self.import_details.last.save
          end
          row_i += 1
        end
      end

      post_import_tasks

      self.status = :finished
      self.save
    rescue Exception => e
      Rails.logger.warn e.message
      self.update_attribute(:status, :failed)
    end
  end
  
  # @return [Contact]
  def map_contact(external_id)
    local_contact = Contact.where(external_sysname: 'Kshema', external_id: external_id).first
    if local_contact
      local_contact
    else
      c = PadmaContact.find_by_kshema_id(external_id)
      if c
        Contact.get_by_padma_id(c.id,self.account.id, c, {external_sysname: 'Kshema', external_id: external_id})
      end
    end
  end

  def failed_rows_to_csv
    import_csv = CSV.read(self.csv_file.file.path)
    unless import_csv.nil?
      CSV.generate do |failed_rows_csv|
        failed_rows_csv << ['row'] + self.headers + ['error message'] 
        self.failed_rows.each do |failed_row|
          failed_rows_csv << [failed_row.value] + import_csv[failed_row.value] + [failed_row.message]
        end
      end 
    end
  end

  private

  def csv_file_handle
    @csv_file_handle ||= if Rails.env.test? || Rails.env.development?
      open(self.csv_file.path)
    else
      open(self.csv_file.url)
    end
  end

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
      unless (self.headers.reject {|x| x.blank?} - self.valid_headers).empty?
        errors.add(:headers, 'invalid headers')
      end
    end
  end

  def log(txt)
    Rails.logger.debug "[#{self.type} #{self.id}] #{txt}"
  end

end
