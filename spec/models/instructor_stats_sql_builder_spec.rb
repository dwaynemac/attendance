require 'rails_helper'

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

  describe "#sql" do
    let(:account){create(:account)}
    let(:user1){create(:user, username: '368152al1ex_fa2lke@hotmail.com', current_account_id: account.id)}
    let(:user2){create(:user, username: 'alex.falke', current_account_id: account.id)}
    let(:user3){create(:user, username: 'dwayne_macgowan@hotmail.com', current_account_id: account.id)}
    let(:issb){InstructorStatsSQLBuilder.new(account: account)}

    before do
      allow(account).to receive(:usernames).and_return([user1.username, user2.username, user3.username])
    end

    context "when users have special characters in their usernames" do
      context "#distribution" do
        it "should return an array of hashes" do
          expect(issb.distribution.is_a?(Array)).to be_truthy
          expect(issb.distribution.size).to eq 3
          expect(issb.distribution.first.is_a?(Hash)).to be_truthy
        end
        it "should contain usernames" do
          expect(issb.distribution.map{|u| u[:username]}).to match_array([user1.username, user2.username, user3.username])
        end
        it "should contain digest of usernames" do
          expect(issb.distribution.map{|u| u[:sql_username]}).to match_array(
            ["_#{Digest::MD5.hexdigest(user1.username)}", "_#{Digest::MD5.hexdigest(user2.username)}", "_#{Digest::MD5.hexdigest(user3.username)}"])
        end
        it "should contain each username and its sql username" do
          expect(issb.distribution.detect{|u| u[:username] == user1.username}[:sql_username]).to eq "_#{Digest::MD5.hexdigest(user1.username)}"
        end
      end

      context "#distribution_names" do
        it "should return array of usernames, not sql_usernames" do
          expect(issb.distribution_names).to match_array([user1.username, user2.username, user3.username])
        end
      end

      it "should create sql sentence correcly" do
        expect{Contact.find_by_sql(issb.sql)}.not_to raise_error
      end
    end

  end
end
