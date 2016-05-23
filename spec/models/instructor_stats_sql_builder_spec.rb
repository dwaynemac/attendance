require 'spec_helper'

describe InstructorStatsSQLBuilder do
  describe "status_condition" do
    describe "if include_former_students is true" do
      let(:issb){InstructorStatsSQLBuilder.new('include_former_students' => '1')}
      it "ORs students and former_students" do
        expect(issb.status_condition).to eq "( accounts_contacts.padma_status = 'student' OR accounts_contacts.padma_status = 'former_student' )"
      end
    end
    describe "if include_former_students is false" do
      let(:issb){InstructorStatsSQLBuilder.new('include_former_students' => '0')}
      it "includes only students" do
        expect(issb.status_condition).to eq "( accounts_contacts.padma_status = 'student' )"
      end
    end
  end
end
