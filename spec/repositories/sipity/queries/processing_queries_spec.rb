require "rails_helper"
require 'sipity/queries/processing_queries'

# Welcome intrepid developer. You have stumbled into some complex data
# interactions. There are a lot of data collaborators regarding these tests.
# I would love this to be more in isolation, but that is not in the cards as
# there are at least 16 database tables interacting to ultimately answer the
# following question:
#
# * What actions can a given user take on an entity?
#
# I don't know how we'll be interacting with these tests going forward, but I'm
# hoping a sane pattern will emerge. This may be a case for data fixtures, to
# help offload the mental processing of all of these blood let statements.
#
# But that is a future concern.
#
# REVIEW: How can we move towards testing the database seeds for ETDs?
module Sipity
  module Queries
    RSpec.describe ProcessingQueries, type: :isolated_repository_module do
      let(:user) { User.find_or_create_by!(username: 'user') }
      let(:group) { Models::Group.find_or_create_by!(name: 'group') }
      let(:role) { Models::Role.find_or_create_by!(name: Models::Role.valid_names.first) }
      let(:strategy) { Models::Processing::Strategy.find_or_create_by!(name: 'strategy') }
      let(:entity) do
        Models::Processing::Entity.find_or_create_by!(proxy_for: work, strategy: strategy, strategy_state: originating_state)
      end
      let(:work_area) do
        Models::WorkArea.find_or_create_by!(name: 'ETD', slug: 'etd', partial_suffix: 'etd', demodulized_class_prefix_name: 'etd')
      end
      let(:work) do
        Models::Work.find_or_create_by!(id: 'abc', title: 'Hello', work_type: 'doctoral_dissertation').tap do |the_work|
          allow(the_work).to receive(:work_area).and_return(work_area)
        end
      end
      let(:user_processing_actor) do
        Models::Processing::Actor.find_or_create_by!(proxy_for: user)
      end
      let(:group_processing_actor) do
        Models::Processing::Actor.find_or_create_by!(proxy_for: group)
      end
      let(:strategy_role) { Models::Processing::StrategyRole.find_or_create_by!(role: role, strategy: strategy) }
      let(:user_strategy_responsibility) do
        Models::Processing::StrategyResponsibility.find_or_create_by!(strategy_role: strategy_role, actor: user_processing_actor)
      end
      let(:entity_specific_responsibility) do
        Models::Processing::EntitySpecificResponsibility.find_or_create_by!(
          strategy_role: strategy_role, actor: user_processing_actor, entity: entity
        )
      end
      let(:action) { Models::Processing::StrategyAction.find_or_create_by!(strategy: strategy, name: 'complete') }
      let(:originating_state) { Models::Processing::StrategyState.find_or_create_by!(strategy: strategy, name: 'new') }
      let(:resulting_state) { Models::Processing::StrategyState.find_or_create_by!(strategy: strategy, name: 'done') }
      let(:strategy_state_action) do
        Models::Processing::StrategyStateAction.find_or_create_by!(originating_strategy_state: originating_state, strategy_action: action)
      end
      let(:action_permission) do
        Models::Processing::StrategyStateActionPermission.find_or_create_by!(
          strategy_role: strategy_role, strategy_state_action: strategy_state_action
        )
      end

      context '#processing_state_names_for_select_within_work_area' do
        before { Sipity::SpecSupport.load_database_seeds!(seeds_path: 'db/seeds/etd_work_area_seeds.rb') }
        let(:work_area) { Models::WorkArea.first! }
        let(:results_array) { ["advisor_changes_requested", "back_from_cataloging", "deactivated", "grad_school_approved_but_waiting_for_routing",
        "grad_school_changes_requested", "ingested", "ingesting", "new", "ready_for_cataloging", "ready_for_doi_minting",
        "minting_doi", "ready_for_ingest", "under_advisor_review", "under_grad_school_review"] }
        subject { test_repository.processing_state_names_for_select_within_work_area(work_area: work_area) }

        # This is a fragile test based on the state of data; However it
        # demonstrates what's working
        it 'will return actions associated with the work area' do
          expect(subject).to match_array(results_array)
        end
      end

      context '#scope_actors_associated_with_entity_and_role' do
        subject { test_repository.scope_actors_associated_with_entity_and_role(role: role, entity: entity) }
        it 'will return an array' do
          user_processing_actor
          group_processing_actor
          user_strategy_responsibility
          Models::Processing::EntitySpecificResponsibility.find_or_create_by!(
            strategy_role: strategy_role, actor: group_processing_actor, entity: entity
          )
          returned_value = subject
          expect(returned_value.count).to eq(2)
          expect(returned_value.first.actor_processing_relationship).
            to eq(Models::Processing::Actor::STRATEGY_LEVEL_ACTOR_PROCESSING_RELATIONSHIP)
          expect(returned_value.last.actor_processing_relationship).
            to eq(Models::Processing::Actor::ENTITY_LEVEL_ACTOR_PROCESSING_RELATIONSHIP)
        end
      end

      context '#scope_processing_strategy_roles_for_user_and_entity' do
        subject { test_repository.scope_processing_strategy_roles_for_user_and_entity(user: user, entity: entity) }
        it "will include the strategy specific roles for the given user" do
          user_processing_actor
          user_strategy_responsibility
          expect(subject).to eq([strategy_role])
        end
        it "will include the entity specific specific roles for the given user" do
          user_processing_actor
          entity_specific_responsibility
          expect(subject).to eq([strategy_role])
        end
      end

      context '#scope_roles_associated_with_the_given_entity' do
        subject { test_repository.scope_roles_associated_with_the_given_entity(entity: entity) }
        it 'will return an array' do
          strategy_role # Setting up the data
          expect(subject).to eq([role])
        end
      end

      context '#scope_processing_actors_for' do
        context 'with a user' do
          subject { test_repository.scope_processing_actors_for(user: user) }
          it 'will return an empty enumerable if the user is nil' do
            user_processing_actor
            group_processing_actor
            Models::GroupMembership.create(user_id: user.id, group_id: group.id)
            subject = test_repository.scope_processing_actors_for(user: nil)
            expect(subject).to eq([])
            expect(subject).to be_a(ActiveRecord::Relation)
          end
          it 'will return an enumerable of both user and group' do
            user_processing_actor
            group_processing_actor
            Models::GroupMembership.create(user_id: user.id, group_id: group.id)
            expect(subject).to eq([user_processing_actor, group_processing_actor])
          end
        end
        context 'with a group' do
          subject { test_repository.scope_processing_actors_for(user: group_processing_actor) }
          it 'will return an enumerable of both user and group' do
            group_processing_actor
            Models::GroupMembership.create(user_id: user.id, group_id: group.id)
            expect(subject).to eq([group_processing_actor])
          end
        end
      end

      context '#scope_processing_entities_for_the_user_and_proxy_for_type' do
        before do
          Sipity::SpecSupport.load_database_seeds!(
            seeds_path: 'spec/fixtures/seeds/scope_processing_entities_for_the_user_and_proxy_for_type.rb'
          )
        end
        subject do
          test_repository.scope_proxied_objects_for_the_user_and_proxy_for_type(user: user, proxy_for_type: Sipity::Models::Work)
        end
        let(:user) { User.create!(username: 'user') }
        let(:advisor) { User.create!(username: 'advising') }
        let(:no_access) { User.create!(username: 'no_access') }
        let(:submission_window) { Models::SubmissionWindow.new(id: 111, slug: 'one', work_area_id: 222) }
        let(:second_submission_window) { Models::SubmissionWindow.new(id: 333, slug: 'two', work_area_id: 222) }
        let(:commands) { CommandRepository.new }

        it "will resolve to an array of entities" do
          submission_window.save!
          second_submission_window.save!
          work_one = commands.create_work!(
            submission_window: submission_window,
            title: '1 One',
            work_type: 'doctoral_dissertation',
            work_publication_strategy: 'will_not_publish'
          )
          work_two = commands.create_work!(
            submission_window: submission_window,
            title: '2 Two',
            work_type: 'doctoral_dissertation',
            work_publication_strategy: 'will_not_publish'
          )
          work_three = commands.create_work!(
            submission_window: submission_window,
            title: '3 Three',
            work_type: 'doctoral_dissertation',
            work_publication_strategy: 'will_not_publish'
          )
          work_four = commands.create_work!(
            submission_window: second_submission_window,
            title: '4 Four',
            work_type: 'doctoral_dissertation',
            work_publication_strategy: 'will_not_publish'
          )

          work_four.additional_attributes.create!(key: 'alternate_title', value: "The Lost One of Dire Warning")

          # Adding these to test that multiple additional attributes
          # don't accidentally add multiple records for the same work.
          work_four.additional_attributes.create!(key: 'program_name', value: "Program Name One")
          work_four.additional_attributes.create!(key: 'program_name', value: "Program Name Two")

          commands.grant_creating_user_permission_for!(entity: work_one, user: user)
          commands.grant_creating_user_permission_for!(entity: work_two, user: user)
          commands.grant_creating_user_permission_for!(entity: work_four, user: user)
          # I need two users that have created something; Prior to fixing
          # https://github.com/ndlib/sipity/issues/671, if any user a creating
          # user they were treated as always having access to the object.
          commands.grant_creating_user_permission_for!(entity: work_three, user: advisor)

          commands.grant_processing_permission_for!(entity: work_one, actor: advisor, role: 'advising')
          # Removing some duplication
          parameter_builder = -> (**kwargs) { Sipity::Parameters::SearchCriteriaForWorksParameter.new(**kwargs) }
          sorter = ->(a, b) { a.id <=> b.id } # Because IDs may not be sorted

          expect(
            test_repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
              criteria: parameter_builder.call(user: user, page: 1)
            ).sort(&sorter)
          ).to eq([work_one, work_two, work_four].sort(&sorter))

          expect(
            test_repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
              criteria: parameter_builder.call(user: user, page: 1, per: 1, order: 'title ASC')
            )
          ).to eq([work_one])

          expect(
            test_repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
              criteria: parameter_builder.call(user: user, processing_state: 'new')
            ).sort(&sorter)
          ).to eq([work_one, work_four, work_two].sort(&sorter))

          expect(
            test_repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
              criteria: parameter_builder.call(user: user, processing_state: 'new', order: 'title DESC')
            )
          ).to eq([work_four, work_two, work_one])

          expect(
            test_repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
              criteria: parameter_builder.call(user: user, q: 'One')
            ).sort(&sorter)
          ).to eq([work_one, work_four].sort(&sorter))

          expect(
            test_repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
              criteria: parameter_builder.call(user: user, processing_states: ['hello'])
            )
          ).to eq([])

          expect(
            test_repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
              criteria: parameter_builder.call(user: advisor)
            ).sort(&sorter)
          ).to eq([work_one, work_three].sort(&sorter))

          expect(
            test_repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
              criteria: parameter_builder.call(user: no_access)
            )
          ).to eq([])

          expect(
            test_repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
              criteria: parameter_builder.call(user: user, submission_window: second_submission_window.slug)
            )
          ).to eq([work_four])
        end
      end

      context '#scope_proxied_objects_for_the_user_and_proxy_for_type' do
        before do
          Sipity::SpecSupport.load_database_seeds!(seeds_path: 'spec/fixtures/seeds/trigger_work_state_change.rb')
        end
        let(:strategy) { Models::Processing::Strategy.first! }
        let(:originating_state) { Models::Processing::StrategyState.first! }
        let(:user) { User.create!(username: 'user') }
        let(:criteria) { Sipity::Parameters::SearchCriteriaForWorksParameter.new(user: user, proxy_for_type: Sipity::Models::Work) }
        subject do
          test_repository.scope_proxied_objects_for_the_user_and_proxy_for_type(criteria: criteria)
        end

        it "will resolve to an array of entities" do
          work = Models::Work.create!(id: 1)
          entity = Models::Processing::Entity.find_or_create_by!(proxy_for: work, strategy: strategy, strategy_state: originating_state)
          user_actor = Models::Processing::Actor.find_or_create_by!(proxy_for: user)
          Models::Processing::EntitySpecificResponsibility.find_or_create_by!(
            strategy_role: strategy_role, actor: user_actor, entity: entity
          )
          Models::Processing::StrategyResponsibility.find_or_create_by!(strategy_role: strategy_role, actor: user_actor)

          expect(subject).to eq([work])
        end
      end

      context '#scope_users_for_entity_and_roles' do
        subject { test_repository.scope_users_for_entity_and_roles(entity: entity, roles: role) }
        it "will resolve to an array of users" do
          user = User.create!(username: 'user')
          group_user = User.create!(username: 'group')
          _other_user = User.create!(username: 'other')
          group = Models::Group.find_or_create_by!(name: 'group')
          group_actor = Models::Processing::Actor.find_or_create_by!(proxy_for: group)
          user_actor = Models::Processing::Actor.find_or_create_by!(proxy_for: user)
          Models::GroupMembership.create!(user: group_user, group: group)
          Models::Processing::EntitySpecificResponsibility.find_or_create_by!(
            strategy_role: strategy_role, actor: group_actor, entity: entity
          )
          Models::Processing::StrategyResponsibility.find_or_create_by!(strategy_role: strategy_role, actor: user_actor)

          expect(subject).to eq([user, group_user])
        end
      end

      context "#user_emails_for_entity_and_roles" do
        subject { test_repository.user_emails_for_entity_and_roles(entity: entity, roles: role) }
        it 'will be an array of emails' do
          expect(subject).to be_a(Array)
        end
      end

      context '#scope_strategy_actions_that_are_prerequisites' do
        subject { test_repository.scope_strategy_actions_that_are_prerequisites(entity: entity) }
        let(:guarded_action) { Models::Processing::StrategyAction.find_or_create_by!(strategy_id: strategy.id, name: 'guarded_action') }

        it 'will return an array of actions' do
          Models::Processing::StrategyActionPrerequisite.find_or_create_by!(
            guarded_strategy_action_id: guarded_action.id, prerequisite_strategy_action_id: action.id
          )
          expect(subject).to eq([action])
        end
        it 'will be pluckable' do
          Models::Processing::StrategyActionPrerequisite.find_or_create_by!(
            guarded_strategy_action_id: guarded_action.id, prerequisite_strategy_action_id: action.id
          )
          expect(test_repository.scope_strategy_actions_that_are_prerequisites(entity: entity, pluck: :id)).to eq([action.id])
        end
      end

      context '#scope_processing_strategy_roles_for_user_and_strategy' do
        subject { test_repository.scope_processing_strategy_roles_for_user_and_strategy(user: user, strategy: strategy) }
        it "will include the associated strategy roles for the given user" do
          user_processing_actor
          user_strategy_responsibility
          expect(subject).to eq([strategy_role])
        end
      end

      context '#scope_processing_strategy_roles_for_user_and_entity_specific' do
        subject { test_repository.scope_processing_strategy_roles_for_user_and_entity_specific(user: user, entity: entity) }
        it "will include the associated strategy roles for the given user" do
          user_processing_actor
          entity_specific_responsibility
          expect(subject).to eq([strategy_role])
        end
      end

      context '#scope_permitted_entity_strategy_actions_for_current_state' do
        before do
          Sipity::SpecSupport.load_database_seeds!(
            seeds_path: 'spec/fixtures/seeds/rendering_correct_actions_based_on_user_entity_state.rb'
          )
        end
        let(:user) { User.first! }
        let(:entity) { Sipity::Models::Processing::Entity.first! }

        subject { test_repository.scope_permitted_entity_strategy_actions_for_current_state(user: user, entity: entity) }
        it "will return the correct actions based on user and entity state" do
          expect(subject.pluck(:name)).to eq(['show', 'already_taken_but_by_someone_else'])
        end
      end

      context '#scope_strategy_actions_with_completed_prerequisites' do
        subject { test_repository.scope_strategy_actions_with_completed_prerequisites(entity: entity) }
        it "will include permitted strategy_state_actions" do
          other_guarded_action = Models::Processing::StrategyAction.find_or_create_by!(
            strategy_id: strategy.id, name: 'without_completed_prereq'
          )
          guarded_action = Models::Processing::StrategyAction.find_or_create_by!(strategy_id: strategy.id, name: 'with_completed_prereq')
          action.save unless action.persisted?
          Models::Processing::StrategyActionPrerequisite.find_or_create_by!(
            guarded_strategy_action_id: guarded_action.id, prerequisite_strategy_action_id: action.id
          )
          Services::ActionTakenOnEntity.register(entity: entity, action: action, requested_by: user)
          Models::Processing::StrategyActionPrerequisite.find_or_create_by!(
            guarded_strategy_action_id: other_guarded_action.id, prerequisite_strategy_action_id: guarded_action.id
          )
          expect(subject).to eq([guarded_action])
        end
      end

      context '#scope_strategy_actions_with_incomplete_prerequisites' do
        subject { test_repository.scope_strategy_actions_with_incomplete_prerequisites(entity: entity) }
        context 'with some but not all of the prerequisites completed' do
          before do
            Sipity::SpecSupport.load_database_seeds!(
              seeds_path: 'spec/fixtures/seeds/scope_strategy_actions_with_incomplete_prerequisites.rb'
            )
          end
          let(:entity) { Sipity::Models::Processing::Entity.first! }
          let(:incomplete_action) do
            Sipity::Models::Processing::StrategyAction.find_by(name: 'submit_for_review', strategy_id: entity.strategy_id)
          end
          it 'will return only the actions with all prerequisites completed' do
            expect(subject).to eq([incomplete_action])

            # And be plucakble
            expect(test_repository.scope_strategy_actions_with_incomplete_prerequisites(entity: entity, pluck: :id)).
              to eq([incomplete_action.id])
          end
        end
      end

      context '#scope_strategy_actions_without_prerequisites' do
        subject { test_repository.scope_strategy_actions_without_prerequisites(entity: entity) }
        let(:guarded_action) { Models::Processing::StrategyAction.find_or_create_by!(strategy_id: strategy.id, name: 'with_prereq') }
        it "will include actions that do not have prerequisites" do
          Models::Processing::StrategyActionPrerequisite.find_or_create_by!(
            guarded_strategy_action_id: guarded_action.id, prerequisite_strategy_action_id: action.id
          )
          action.save! unless action.persisted?
          expect(subject).to eq([action])
        end
      end

      context '#scope_statetegy_actions_that_have_occurred' do
        subject { test_repository.scope_statetegy_actions_that_have_occurred(entity: entity) }
        it "will include actions that do not have prerequisites" do
          Services::ActionTakenOnEntity.register(entity: entity, action: action, requested_by: user)
          expect(subject).to eq([action])
        end
        it "will allow you to pluck entries" do
          Services::ActionTakenOnEntity.register(entity: entity, action: action, requested_by: user)
          expect(test_repository.scope_statetegy_actions_that_have_occurred(entity: entity, pluck: :id)).to eq([action.id])
        end
      end

      context '#scope_strategy_actions_available_for_current_state' do
        subject { test_repository.scope_strategy_actions_available_for_current_state(entity: entity) }
        let(:guarded_action) do
          Models::Processing::StrategyAction.find_or_create_by!(strategy_id: strategy.id, name: 'with_completed_prereq')
        end
        let(:other_guarded_action) do
          Models::Processing::StrategyAction.find_or_create_by!(strategy_id: strategy.id, name: 'without_completed_prereq')
        end
        it "will include permitted strategy_state_actions" do
          action.save unless action.persisted?
          [action, guarded_action, other_guarded_action].each do |the_action|
            Models::Processing::StrategyStateAction.find_or_create_by!(
              strategy_action_id: the_action.id, originating_strategy_state_id: entity.strategy_state_id
            )
          end
          Models::Processing::StrategyActionPrerequisite.find_or_create_by!(
            guarded_strategy_action_id: guarded_action.id, prerequisite_strategy_action_id: action.id
          )

          Services::ActionTakenOnEntity.register(entity: entity, action: action, requested_by: user)

          Models::Processing::StrategyActionPrerequisite.find_or_create_by!(
            guarded_strategy_action_id: other_guarded_action.id, prerequisite_strategy_action_id: guarded_action.id
          )
          expect(subject).to eq([action, guarded_action])
        end
      end

      context '#users_that_have_taken_the_action_on_the_entity' do
        subject { test_repository.users_that_have_taken_the_action_on_the_entity(entity: entity, actions: action) }
        it "will include permitted strategy_state_actions" do
          user = User.create!(username: 'user')
          other_user = User.create!(username: 'another_user')
          groupy = User.create!(username: 'groupy')
          Models::GroupMembership.create(user_id: groupy.id, group_id: group.id)
          Conversions::ConvertToProcessingActor.call(user)
          Conversions::ConvertToProcessingActor.call(other_user)
          Conversions::ConvertToProcessingActor.call(group)
          Services::ActionTakenOnEntity.register(entity: entity, action: action, requested_by: user)
          Services::ActionTakenOnEntity.register(entity: entity, action: action, requested_by: group)
          expect(subject).to eq([user, groupy])
        end
      end

      context '#collaborators_that_have_taken_the_action_on_the_entity' do
        subject { test_repository.collaborators_that_have_taken_the_action_on_the_entity(entity: entity, actions: action) }
        it "will include permitted strategy_state_actions" do
          user = User.create!(username: 'user')
          non_acting_user = User.create!(username: 'non_acting_user')
          other_user = User.create!(username: 'another_user')
          groupy = User.create!(username: 'groupy')
          user_acting_collaborator = Models::Collaborator.create!(
            name: 'user_acting', netid: user.username, responsible_for_review: true, role: 'Committee Member', work_id: entity.proxy_for_id
          )
          acting_via_email_collaborator = Models::Collaborator.create!(
            name: 'acting_via_email',
            email: 'another@gmail.com',
            responsible_for_review: true,
            role: 'Committee Member',
            work_id: entity.proxy_for_id
          )
          group_collaborator = Models::Collaborator.create!(
            name: 'groupy', netid: groupy.username, responsible_for_review: true, role: 'Committee Member', work_id: entity.proxy_for_id
          )

          not_yet_acted_collaborator = Models::Collaborator.create!(
            name: 'not_yet_acted_collaborator',
            email: 'not_yet_acted_collaborator@gmail.com',
            responsible_for_review: true,
            role: 'Committee Member',
            work_id: entity.proxy_for_id
          )
          Models::GroupMembership.create(user_id: groupy.id, group_id: group.id)

          [
            user, non_acting_user, other_user, groupy, user_acting_collaborator, acting_via_email_collaborator, not_yet_acted_collaborator
          ].each do |proxy_for_actor|
            Conversions::ConvertToProcessingActor.call(proxy_for_actor)
          end

          Models::Collaborator.create!(
            name: 'non_reviewing', role: 'Committee Member', responsible_for_review: false, work_id: entity.proxy_for_id
          )
          Services::ActionTakenOnEntity.register(entity: entity, action: action, requested_by: user)
          Services::ActionTakenOnEntity.register(entity: entity, action: action, requested_by: group)
          Services::ActionTakenOnEntity.register(entity: entity, action: action, requested_by: acting_via_email_collaborator)
          expect(subject.pluck(:name).sort).to eq(
            [
              user_acting_collaborator.name,
              acting_via_email_collaborator.name,
              group_collaborator.name
            ].sort
          )
        end
      end

      context '#authorized_for_processing?' do
        it 'will return a boolean based on underlying interactions' do
          expect(test_repository).to receive(:scope_permitted_strategy_actions_available_for_current_state).and_call_original
          expect(test_repository.authorized_for_processing?(user: user, entity: entity, action: :show)).to eq(false)
        end
      end

      context '#scope_permitted_strategy_actions_available_for_current_state' do
        subject { test_repository.scope_permitted_strategy_actions_available_for_current_state(entity: entity, user: user) }
        let(:guarded_action) { Models::Processing::StrategyAction.find_or_create_by!(strategy: strategy, name: 'with_prereq') }
        before do
          strategy_role
          user_strategy_responsibility
          action_permission
        end
        it "will compose several other scopes to answer the question" do
          action_with_completed_prerequisites = Models::Processing::StrategyAction.find_or_create_by!(
            strategy: strategy, name: 'completed_prerequisites'
          ) do |current_action|
            current_action.requiring_strategy_action_prerequisites.build(prerequisite_strategy_action: action)
          end
          Services::ActionTakenOnEntity.register(entity: entity, action: action_with_completed_prerequisites, requested_by: user)

          Models::Processing::StrategyAction.find_or_create_by!(strategy: strategy, name: 'with_incomplete_prereqs') do |current_action|
            current_action.requiring_strategy_action_prerequisites.build(
              prerequisite_strategy_action: action_with_completed_prerequisites
            )
          end

          Models::Processing::StrategyStateAction.find_or_create_by!(originating_strategy_state: originating_state, strategy_action: action)

          # Making sure that I have the expected counts
          expect(User.count).to eq(1)
          expect(Models::Processing::Actor.count).to eq(1)
          expect(Models::Processing::StrategyResponsibility.count).to eq(1)
          expect(Models::Processing::EntitySpecificResponsibility.count).to eq(0)
          expect(Models::Processing::StrategyRole.count).to eq(1)

          expect(Models::Role.count).to eq(1)

          expect(Models::Processing::StrategyAction.count).to eq(3)
          expect(Models::Processing::StrategyActionPrerequisite.count).to eq(2)
          expect(Models::Processing::StrategyStateAction.count).to eq(1)
          expect(Models::Processing::StrategyStateActionPermission.count).to eq(1)
          expect(Models::Processing::StrategyState.count).to eq(1)
          expect(Models::Processing::EntityActionRegister.count).to eq(1)
          expect(Models::Processing::Entity.count).to eq(1)

          expect(subject).to eq([action])
        end
      end
    end
  end
end
