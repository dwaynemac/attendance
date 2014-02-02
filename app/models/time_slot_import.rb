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
      student_ids
    )
  end

  def handle_row(row,row_i)
    t = build_time_slot(row)
    if t.save or retry_fixing_errors(t)
      build_time_slot_students(row, t)
      ImportedId.new(value: t.id)
    else
      FailedRow.new(value: row_i, message: t.errors.messages.map{|attr,err_array| "#{attr}: #{err_array.join(' and ')}" }.join(' AND '))
    end
  end

  private

  # @param [CSV::Row]
  # @return [TimeSlot]
  def build_time_slot(row)
    t = TimeSlot.new
    t.account = self.account
    
    st = value_for(row,'start_at')
    t.start_at = Time.parse(st) if st
    et = value_for(row,'end_at')
    t.end_at = Time.parse(et) if et

    (valid_headers-%W(start_at end_at student_ids)).each do |header|
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

  # @param [CSV::Row] row
  # @param [TimeSlot] time_slot
  # @return [TimeSlot]
  def build_time_slot_students(row, time_slot)
    student_ids = value_for(row,'student_ids')
    unless student_ids.blank?
      # cast student_ids to an Array of Integer , these are the remote_ids of contacts
      student_ids = student_ids.split(', ')

      student_ids.each do |stid|
        contact = map_contact(stid)
        time_slot.contact_time_slots.create(contact_id: contact.id)
      end
    end
    time_slot
  end

end
