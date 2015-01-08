require 'spec_helper'

module Sipity
  module Queries
    describe GroupQueries, type: :repository_methods do
      context '#group_names_for_entity_and_roles' do
        Given(:role_name) { 'etd_reviewer' }
        Given(:entity) { Models::Sip.new }
        let(:actor) { Sipity::Factories.create_user(email: 'associated@hotmail.com') }

        it 'returns the group names for the given sip and role' do
          Models::Permission.create!(actor: actor, role: role_name, entity: entity)
          expect(test_repository.group_names_for(entity: entity, role: role_name)).to eq(['graduate_school'])
        end

        it 'will return an empty result if there are no roles' do
          expect(test_repository.group_names_for(entity: entity, role: [])).
            to eq([])
        end
      end
    end
  end
end
