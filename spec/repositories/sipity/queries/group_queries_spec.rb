require 'spec_helper'

module Sipity
  module Queries
    describe GroupQueries, type: :repository_methods do
      context '#group_names_for_entity_and_roles' do
        Given(:role_name) { 'etd_reviewer' }
        let(:entity) { Models::Sip.create! }
        subject { test_repository }

        When(:group_names) {
          Sipity::Commands::PermissionCommands.grant_groups_permission_to_entity_for_role!(entity: entity, roles: role_name)
          subject.group_names_for(entity: entity, role: role_name)
        }
        Then { group_names == ['graduate_school'] }

        it 'will return an empty result if there are no roles' do
          expect(subject.group_names_for(entity: entity, role: [])).
            to eq([])
        end
      end
    end
  end
end
