class TimeSlotImport < Import

  validate :valid_headers

  VALID_HEADERS = %W(
    name
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

  def process_CSV
  end

  private

  def valid_headers
    unless (self.headers - VALID_HEADERS).empty?
      errors.add(:headers, 'invalid headers')
    end
  end

end
