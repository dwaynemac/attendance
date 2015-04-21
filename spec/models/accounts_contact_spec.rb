require 'spec_helper'

describe AccountsContact do
  it { should belong_to(:contact) }
	
  it { should belong_to(:account) }
  
end
