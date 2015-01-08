require 'spec_helper'

module Sipity
  module Queries
    # Queries
    RSpec.describe PermissionQueries, type: :repository_methods do
      context '#group_names_for_entity_and_acting_as' do
        Given(:acting_as) { 'etd_reviewer' }
        Given(:entity) { double('Entity') }
        When(:group_names) { test_repository.group_names_for_entity_and_acting_as(entity: entity, acting_as: acting_as) }
        Then { group_names == ['graduate_school'] }
      end

      context '#emails_for_associated_users' do
        let(:entity) { Models::Sip.create! }
        let(:associated_user) { Sipity::Factories.create_user(email: 'associated@hotmail.com') }
        let(:associated_by_group_user) { Sipity::Factories.create_user(email: 'group_associated@hotmail.com') }
        let(:not_associated_user) { Sipity::Factories.create_user(email: 'not_associated@hotmail.com') }
        let(:user_with_wrong_acting_as) { Sipity::Factories.create_user(email: 'wrong_acting_as@hotmail.com') }
        let(:associated_group) { Models::Group.create!(name: 'associated') }
        let(:acting_as) { 'arbitrary' }
        let(:wrong_acting_as) { 'wrong_acting_as' }

        before do
          # REVIEW: Should I be using Repository services?
          Models::GroupMembership.create!(group: associated_group, user: associated_by_group_user)

          Models::Permission.create!(actor: user_with_wrong_acting_as, acting_as: wrong_acting_as, entity: entity)
          Models::Permission.create!(actor: associated_group, acting_as: acting_as, entity: entity)
          Models::Permission.create!(actor: associated_user, acting_as: acting_as, entity: entity)
        end

        it 'will return emails from users directly associated with the entity' do
          results = test_repository.emails_for_associated_users(acting_as: acting_as, entity: entity)
          expect(results.sort).to eq(['associated@hotmail.com', 'group_associated@hotmail.com'])
        end
      end

      context '#scope_entities_for_entity_type_and_user_acting_as' do
        let(:user) { User.new(id: 1234) }
        let(:group) { Models::Group.new(id: 5678) }
        let(:entity) { Models::Sip.create! }
        let(:acting_as) { Models::Permission::CREATING_USER }
        subject { test_repository }

        it 'will return an empty result if there are no acting_as' do
          Models::Permission.create!(entity: entity, actor: user, acting_as: acting_as)
          expect(subject.scope_entities_for_entity_type_and_user_acting_as(user: user, acting_as: [], entity_type: entity.class)).
            to_not include(entity)
        end
        it 'will return the entity for the creating user' do
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor: user, acting_as: acting_as)
          expect(subject.scope_entities_for_entity_type_and_user_acting_as(user: user, acting_as: acting_as, entity_type: entity.class)).
            to include(entity)
        end

        it 'will exclude the entity for a non creating user' do
          expect(subject.scope_entities_for_entity_type_and_user_acting_as(user: user, acting_as: acting_as, entity_type: entity.class)).
            to_not include(entity)
        end

        it 'will return the entity for which the user is inferred by group' do
          Models::GroupMembership.create!(user: user, group: group)
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor: group, acting_as: acting_as)
          expect(subject.scope_entities_for_entity_type_and_user_acting_as(user: user, acting_as: acting_as, entity_type: entity.class)).
            to include(entity)
        end

        it 'will exclude the entity for which the user is not part of the group' do
          Models::Permission.create!(entity: entity, actor: group, acting_as: acting_as)
          expect(subject.scope_entities_for_entity_type_and_user_acting_as(user: user, acting_as: acting_as, entity_type: entity.class)).
            to_not include(entity)
        end
      end
    end
  end
end
