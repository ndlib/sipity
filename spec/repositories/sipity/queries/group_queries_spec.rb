require 'spec_helper'

module Sipity
  module Queries
    describe GroupQueries, type: :repository_methods do
      context '#group_names_for_entity_and_roles' do
        Given(:role_name) { 'etd_reviewer' }
        Given(:entity) { Models::Entity.new }
        When(:group_names) { test_repository.roles_for_entity_and_group_name(entity: entity, role: role_name) }
        Then { group_names == ['graduate_school'] }
      end
    end
  end
end
