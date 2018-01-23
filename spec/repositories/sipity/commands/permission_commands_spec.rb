require "rails_helper"
require 'sipity/commands/permission_commands'

module Sipity
  module Commands
    RSpec.describe PermissionCommands, type: :isolated_repository_module do
      subject { test_repository }
      before do
      end

      context '#grant_creating_user_permission_for!' do
        # REVIEW: The entity, user, and group are all being created. Is it time
        #   to consider using fixtures?
        let(:entity) { Models::Work.new(id: 1) }
        let(:user) { User.new(id: 2) }
        let(:group) { Models::Group.new(id: 3) }

        it 'will use the :user parameter to write a permission' do
          # TODO: Remove this once the deprecation for granting permission is done
          allow(Services::GrantProcessingPermission).to receive(:call)
          subject.grant_creating_user_permission_for!(entity: entity, user: user)
        end
      end

      context '#revoke_permission_for!' do
        let(:entity) { Models::Work.new(id: 1) }
        let(:user) { User.new(id: 2) }
        let(:group) { Models::Group.new(id: 3) }

        it 'will revoke the given role for each of the given actors' do
          expect(Services::RevokeProcessingPermission).to receive(:call).with(entity: entity, actor: user, role: 'A Role')
          expect(Services::RevokeProcessingPermission).to receive(:call).with(entity: entity, actor: group, role: 'A Role')
          subject.revoke_permission_for!(entity: entity, actors: [user, group], acting_as: 'A Role')
        end
      end
    end
  end
end
