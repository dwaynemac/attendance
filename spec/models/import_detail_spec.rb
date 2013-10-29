require 'spec_helper'

describe ImportDetail do
  it { should belong_to :import }
  it { should validate_presence_of :value }
end
