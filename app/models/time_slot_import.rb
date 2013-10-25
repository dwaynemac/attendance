require 'csv'
require 'open-uri' # todo do we need this here?

# header nil is used to ignore a column
class TimeSlotImport < Import

  def valid_headers
    %W(
      external_id
      name
      padma_uid
      start_at
      end_at
      monday
      tuesday
      wednesday
      thursday
      friday
      saturday
      sunday
      cultural_activity
      observations
    )
  end

  def process_CSV
    return unless self.status == :ready

    file_handle = open(self.csv_file.file.path)
    unless file_handle.nil?
      row_i = 1 # start at 1 because first row is skipped
      CSV.foreach(file_handle, encoding:"UTF-8:UTF-8", headers: :first_row) do |row|
        t = build_time_slot(row)

        if t.save || retry_fixing_errors(t)
          self.imported_ids << t.id
        else
          self.failed_rows << row_i
        end
        row_i += 1
      end
    end

    self.status = :finished
    self.save
  end

  private

  # @param [CSV::Row]
  # @return [TimeSlot]
  def build_time_slot(row)
    t = TimeSlot.new
    t.account = self.account
    
    valid_headers.each do |header|
      if index_for(header)
        t.send("#{header}=",value_for(row,header))
      end
    end

    t
  end

  # @params [TimeSlot]
  # @return [Boolean]
  def retry_fixing_errors(time_slot)
    # fix missing end_at
    if time_slot.errors[:end_at][0] =~ /is not a valid time/ && time_slot.errors[:start_at].empty?
      time_slot.end_at = time_slot.start_at+1.minute
    end
    time_slot.save
  end

end
