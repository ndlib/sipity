require "rails_helper"
require 'sipity/commands/administrative_commands'

module Sipity
  module Commands
    RSpec.describe AdministrativeCommands, type: :isolated_repository_module do
      describe "#set_group_membership" do
        let(:group_name) { 'my group' }
        let(:username) { 'my user' }
        subject do
          test_repository.set_group_membership(
            group_name: group_name,
            usernames: username,
            force_membership_to_these_usernames: force_membership_to_these_usernames
          )
        end
        before do
          allow_any_instance_of(User).to receive(:call_on_create_user_service).and_return(true)
        end
        context 'when :force_membership_to_these_usernames is false' do
          let(:force_membership_to_these_usernames) { false }
          it 'will create the group if none exists otherwise it will re-use it' do
            expect { subject }.to change { Sipity::Models::Group.count }
            expect { subject }.not_to change { Sipity::Models::Group.count }
          end
          it 'will create the user if none exists otherwise it will re-use it' do
            expect { subject }.to change { User.count }
            expect { subject }.not_to change { User.count }
          end
          it 'will assign the user to the given group' do
            expect { subject }.to change { Sipity::Models::GroupMembership.count }
            user = User.find_by!(username: username)
            group = Sipity::Models::Group.find_by!(name: group_name)
            expect(user.group_memberships.map(&:group)).to eq([group])
          end
          it 'will preserve users that are already members in the given group' do
            other_user = User.find_or_create_by!(username: 'another username')
            test_repository.set_group_membership(
              group_name: group_name,
              usernames: [other_user.username],
              force_membership_to_these_usernames: force_membership_to_these_usernames
            )
            expect { subject }.not_to change { other_user.group_memberships.count }
          end
        end
        context 'when :force_membership_to_these_usernames is true' do
          let(:force_membership_to_these_usernames) { true }
          it 'will create the group if none exists otherwise it will re-use it' do
            expect { subject }.to change { Sipity::Models::Group.count }
            expect { subject }.not_to change { Sipity::Models::Group.count }
          end
          it 'will create the user if none exists otherwise it will re-use it' do
            expect { subject }.to change { User.count }
            expect { subject }.not_to change { User.count }
          end
          it 'will assign the user to the given group' do
            expect { subject }.to change { Sipity::Models::GroupMembership.count }
            user = User.find_by!(username: username)
            group = Sipity::Models::Group.find_by!(name: group_name)
            expect(user.group_memberships.map(&:group)).to eq([group])
          end
          it 'will destroy users that were already members in the given group but not specified in the call' do
            other_user = User.find_or_create_by!(username: 'another username')
            test_repository.set_group_membership(
              group_name: group_name,
              usernames: [other_user.username],
              force_membership_to_these_usernames: force_membership_to_these_usernames
            )
            expect { subject }.to change { other_user.group_memberships.count }.by(-1)
          end
        end
      end
    end
  end
end
