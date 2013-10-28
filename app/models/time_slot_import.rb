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

  def handle_row(row)
    t = build_time_slot(row)
    if t.save || retry_fixing_errors(t)
      t.id
    else
      nil
    end
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
