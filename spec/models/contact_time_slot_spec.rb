require 'spec_helper'

describe ContactTimeSlot do
  it { should validate_presence_of :time_slot_id }
  it { should validate_presence_of :contact_id }
end
