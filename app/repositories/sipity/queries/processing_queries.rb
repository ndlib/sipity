require 'active_support/core_ext/array/wrap'

module Sipity
  module Queries
    # Welcome intrepid developer. You have stumbled into some complex data
    # interactions. There are a lot of data collaborators regarding these tests.
    # I would love this to be more in isolation, but that is not in the cards as
    # there are at least 16 database tables interacting to ultimately answer the
    # following question:
    #
    # * What actions can a given user take on an entity?
    #
    # Could there be more efficient queries? Yes. However, the composition of
    # queries has proven to be a very powerful means of understanding and
    # exploring the problem.
    #
    # @note There is an indication of public or private api. The intent of this
    #   is to differentiate what are methods that are the primary entry points
    #   as understood as of the commit that has the @api tag. However, these are
    #   public methods because they have been tested in isolation and are used
    #   to help compose the `@api public` methods.
    module ProcessingQueries
      # @api public
      #
      # This query returns a unique set of state names that are associated
      # with one or more object (of usage_type) for the given work area.
      #
      # @example
      #   Given work area WA
      #   And given work type WT1 and WT2 are in WA.
      #   And WT1 has strategy states with names SS1, SS2, SS3
      #   And WT2 has strategy states with names SS1, SS2, SS4
      #   When we call #processing_state_names_for_select_within_work_area(work_area: WA)
      #   Then we will get back action names: [SS1, SS2, SS3, SS4]
      #
      # @param work_area [Object] that can be converted into a Sipity::Models::WorkArea
      # @param usage_type [Object] the polymorphic type for database storage
      #
      # @return [Array<String>] name of actions available
      def processing_state_names_for_select_within_work_area(work_area:, usage_type: Sipity::Models::WorkType)
        work_area = PowerConverter.convert(work_area, to: :work_area)
        usage_type = Conversions::ConvertToPolymorphicType.call(usage_type)

        strategy_states = Models::Processing::StrategyState.arel_table
        strategy_usages = Models::Processing::StrategyUsage.arel_table
        submission_window_work_types = Models::SubmissionWindowWorkType.arel_table
        submission_windows = Models::SubmissionWindow.arel_table

        select_manager = strategy_states.project(strategy_states[:name]).order(strategy_states[:name]).distinct.join(strategy_usages).on(
          strategy_usages[:strategy_id].eq(strategy_states[:strategy_id]).and(
            strategy_usages[:usage_type].eq(usage_type)
          )
        ).join(submission_window_work_types).on(
          submission_window_work_types[:work_type_id].eq(strategy_usages[:usage_id])
        ).join(submission_windows).on(
          submission_windows[:id].eq(submission_window_work_types[:submission_window_id]).and(
            submission_windows[:work_area_id].eq(work_area.id)
          )
        )

        Models::Processing::StrategyState.from(strategy_states.create_table_alias(select_manager, strategy_states.table_name)).pluck(:name)
      end

      # @api public
      #
      # Actors associated with the given :entity and how they are associated
      # with the given.
      #
      # @param entity [Object] that can be converted into a Sipity::Models::Processing::Entity
      # @param role [Object] that can be converted into a Sipity::Models::Role
      # @return [ActiveRecord::Relation<Actor>] augmented with
      def scope_actors_associated_with_entity_and_role(entity:, role:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        role = Conversions::ConvertToRole.call(role)
        strategy_roles = Models::Processing::StrategyRole.arel_table
        strategy_responsibilities = Models::Processing::StrategyResponsibility.arel_table
        entity_responsibilities = Models::Processing::EntitySpecificResponsibility.arel_table

        actors = Models::Processing::Actor.arel_table

        actors_select_manager = actors.project(
          :*,
          Arel.sql("'#{Models::Processing::Actor::ENTITY_LEVEL_ACTOR_PROCESSING_RELATIONSHIP}'").as('actor_processing_relationship')
        ).where(
          actors[:id].in(
            entity_responsibilities.project(entity_responsibilities[:actor_id]).join(strategy_roles).on(
              strategy_roles[:id].eq(entity_responsibilities[:strategy_role_id])
            ).where(
              entity_responsibilities[:entity_id].eq(entity.id).and(
                strategy_roles[:role_id].eq(role.id)
              )
            )
          )
        ).union(
          actors.project(
            :*,
            Arel.sql("'#{Models::Processing::Actor::STRATEGY_LEVEL_ACTOR_PROCESSING_RELATIONSHIP}'").as('actor_processing_relationship')
          ).where(
            actors[:id].in(
              strategy_responsibilities.project(strategy_responsibilities[:actor_id]).join(strategy_roles).on(
                strategy_roles[:id].eq(strategy_responsibilities[:strategy_role_id])
              ).where(
                strategy_roles[:strategy_id].eq(entity.strategy_id).and(
                  strategy_roles[:role_id].eq(role.id)
                )
              )
            )
          )
        )
        # I would love to use the following:
        #  `Models::Processing::Actor.find_by_sql(actors_select_manager.to_sql)`
        #
        # However AREL is adding an opening and closing parenthesis to the query
        # statement. So I needed to massage that output, as follows:
        #
        # ```ruby
        #  Models::Processing::Actor.find_by_sql(
        #    actors_select_manager.to_sql.sub(/\A\s*\(\s*(.*)\s*\)\s*\Z/,'\1')
        #  )
        # ```
        #
        # Instead I'm taking an example from:
        # https://github.com/danshultz/mastering_active_record_sample_code/blob/a656c60ca7a2e27b5cd1aadbdf3bdc1814c37000/app/models/beer.rb#L77-L81
        #
        # Note, I'm making a dynamic query with a result the same as the table
        # name of the model that I'm using.
        Models::Processing::Actor.from(actors.create_table_alias(actors_select_manager, actors.table_name)).all
      end

      # @api public
      #
      # Roles associated with the given :entity
      # @param entity [Object] that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Role>]
      def scope_roles_associated_with_the_given_entity(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        strategy_roles = Models::Processing::StrategyRole.arel_table
        Models::Role.where(
          Models::Role.arel_table[:id].in(
            strategy_roles.project(strategy_roles[:role_id]).where(
              strategy_roles[:strategy_id].eq(entity.strategy_id)
            )
          )
        )
      end

      # @api public
      #
      # Is the user authorized to take the processing action on the given
      # entity?
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param action an object that can be converted into a Sipity::Models::Processing::StrategyAction#name
      # @return [Boolean]
      def authorized_for_processing?(user:, entity:, action:)
        action_name = Conversions::ConvertToProcessingActionName.call(action)
        scope_permitted_strategy_actions_available_for_current_state(user: user, entity: entity).
          where(Models::Processing::StrategyAction.arel_table[:name].eq(action_name)).count > 0
      end

      # @api private
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Any user that has taken the action (or someone has taken it on their
      #   behalf)
      # * Any user that is part of a group that has taken the action (you know,
      #   because maybe we'll allow groups to take the action)
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param action an object that can be covnerted into a Sipity::Models::Processing::Action
      #   given the entity
      # @return [ActiveRecord::Relation<User>]
      def users_that_have_taken_the_action_on_the_entity(entity:, actions:)
        users = User.arel_table
        group_memberships = Models::GroupMembership.arel_table

        User.where(
          users[:id].in(
            action_registers_subquery_builder(
              poly_type: User, entity: entity, actions: actions
            )
          ).or(
            users[:id].in(
              group_memberships.project(group_memberships[:user_id]).where(
                group_memberships[:group_id].in(
                  action_registers_subquery_builder(
                    poly_type: Sipity::Models::Group, entity: entity, actions: actions
                  )
                )
              )
            )
          )
        )
      end

      def action_registers_subquery_builder(poly_type:, entity:, actions:)
        actors = Models::Processing::Actor.arel_table
        action_registers = Models::Processing::EntityActionRegister.arel_table
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Array.wrap(actions) { |an_action| Conversions::ConvertToProcessingAction.call(an_action, scope: entity) }
        poly_type = Conversions::ConvertToPolymorphicType.call(poly_type)

        actors.project(actors[:proxy_for_id]).where(
          actors[:proxy_for_type].eq(poly_type)
        ).join(action_registers).on(
          action_registers[:on_behalf_of_actor_id].eq(actors[:id])
        ).where(
          action_registers[:strategy_action_id].in(actions.map(&:id)).
          and(action_registers[:entity_id].eq(entity.id))
        )
      end
      private :action_registers_subquery_builder

      # @api private
      def non_user_collaborators_that_have_taken_the_action_on_the_entity(entity:, actions:)
        Models::Collaborator.where(
          Models::Collaborator.arel_table[:id].in(
            action_registers_subquery_builder(poly_type: Models::Collaborator, entity: entity, actions: actions)
          )
        )
      end
      private :non_user_collaborators_that_have_taken_the_action_on_the_entity

      # @api public
      #
      # Given the :entity and :action generate a ActiveRecord::Relation that
      # meets the following criteria:
      #
      # * A user has taken the action
      # * Someone has taken an action on behalf of a collaborator
      # * Somehow a group has taken an action so return all users
      #
      # @note This stretches out of the processing subsystem and out into the
      #   modeling; It highlights that the domain model has two concepts that
      #   are not properly being teased apart.
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param action an object that can be covnerted into a Sipity::Models::Processing::Action
      #   given the entity
      # @return [ActiveRecord::Relation<User>]
      def collaborators_that_have_taken_the_action_on_the_entity(entity:, actions:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        collaborators = Models::Collaborator.arel_table
        users = User.arel_table
        users_scope = users_that_have_taken_the_action_on_the_entity(entity: entity, actions: actions)
        non_user_collaborator_scope = non_user_collaborators_that_have_taken_the_action_on_the_entity(entity: entity, actions: actions)

        Models::Collaborator.where(
          collaborators[:netid].in(
            users.project(
              users[:username]
            ).where(
              users_scope.constraints.reduce.and(collaborators[:netid].not_eq(nil))
            )
          ).or(
            collaborators[:id].in(
              Models::Collaborator.arel_table.project(
                non_user_collaborator_scope.arel_table[:id]
              ).where(
                non_user_collaborator_scope.constraints.reduce
              )
            )
          )
        ).where(
          collaborators[:work_id].eq(entity.proxy_for_id).and(
            collaborators[:responsible_for_review].eq(true)
          )
        )
      end

      # @api public
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Any unguarded actions
      # * Any guarded action that has had all of its prerequisites completed
      # * Only actions permitted to the user
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_permitted_strategy_actions_available_for_current_state(user:, entity:)
        strategy_actions_scope = scope_strategy_actions_available_for_current_state(entity: entity)
        strategy_state_actions_scope = scope_permitted_entity_strategy_state_actions(user: user, entity: entity)
        strategy_actions_scope.where(
          strategy_actions_scope.arel_table[:id].in(
            strategy_state_actions_scope.arel_table.project(
              strategy_state_actions_scope.arel_table[:strategy_action_id]
            ).where(strategy_state_actions_scope.constraints.reduce)
          )
        )
      end

      # @api public
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Actions that are permitted to the current user
      # * Actions that are available for the entity's current state.
      #
      # AND
      #
      # * Actions that are permitted to be taken multiple times within the
      #   current state OR
      # * Actions that are not allowed to be taken multiple times and have not
      #   yet been taken.
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_permitted_entity_strategy_actions_for_current_state(user:, entity:)
        action_scope = scope_permitted_without_concern_for_repetition_entity_strategy_actions_for_current_state(user: user, entity: entity)

        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actor = Conversions::ConvertToProcessingActor.call(user)
        registers = Models::Processing::EntityActionRegister.arel_table
        analogues = Models::Processing::StrategyActionAnalogue.arel_table

        actions_that_have_not_occurred_for_the_actor = action_scope.arel_table.project(
          action_scope.arel_table[:id]
        ).join(
          registers, Arel::Nodes::OuterJoin
        ).on(
          registers[:entity_id].eq(entity.id).and(
            registers[:on_behalf_of_actor_id].eq(actor.id)
          ).and(
            registers[:strategy_action_id].eq(action_scope.arel_table[:id])
          )
        ).where(
          registers[:strategy_action_id].eq(nil).and(
            action_scope.arel_table[:allow_repeat_within_current_state].eq(false)
          )
        )

        # TODO: This is presently broken up into two queries. It could be
        # consolidated into a single query with a left outer join.
        permitted_ids = action_scope.where(
          action_scope.arel_table[:allow_repeat_within_current_state].eq(true).or(
            action_scope.arel_table[:id].in(
              actions_that_have_not_occurred_for_the_actor
            )
          )
        ).pluck(:id)

        # I have a list of permitted ids. I need to eliminate from the list any
        # ids that have analogs not in the list. However I should keep any ids
        # that can be repeated for a given state.
        action_scope.klass.where(id: permitted_ids).where(
          action_scope.arel_table[:id].not_in(
            analogues.project(
              analogues[:strategy_action_id]
            ).where(
              analogues[:analogous_to_strategy_action_id].not_in(permitted_ids).and(
                analogues[:analogous_to_strategy_action_id].not_eq(analogues[:strategy_action_id])
              )
            )
          ).or(action_scope.arel_table[:allow_repeat_within_current_state].eq(true))
        )
      end

      # @api private
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Actions that are permitted to the current user
      # * Actions that are available for the entity's current state.
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_permitted_without_concern_for_repetition_entity_strategy_actions_for_current_state(user:, entity:)
        strategy_actions = Models::Processing::StrategyAction

        strategy_actions_for_current_state_scope = scope_strategy_actions_for_current_state(entity: entity)
        strategy_state_actions_scope = scope_permitted_entity_strategy_state_actions(user: user, entity: entity)

        strategy_actions.where(
          strategy_actions.arel_table[:id].in(
            strategy_state_actions_scope.arel_table.project(
              strategy_state_actions_scope.arel_table[:strategy_action_id]
            ).where(
              strategy_state_actions_scope.constraints.reduce
            )
          ).and(
            strategy_actions.arel_table[:id].in(
              strategy_actions_for_current_state_scope.arel_table.project(
                strategy_actions_for_current_state_scope.arel_table[:id]
              ).where(
                strategy_actions_for_current_state_scope.constraints.reduce
              )
            )
          )
        )
      end
      private :scope_permitted_without_concern_for_repetition_entity_strategy_actions_for_current_state

      # @api public
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * All of the Processing Actors directly associated with the given :user
      # * All of the Processing Actors indirectly associated with the given
      #   :user through the user's group membership.
      #
      # @param user [User]
      # @return [ActiveRecord::Relation<Models::Processing::Actor>]
      def scope_processing_actors_for(user:)
        return Models::Processing::Actor.where('1 = 0') unless user.present?

        memb_table = Models::GroupMembership.arel_table
        actor_table = Models::Processing::Actor.arel_table

        group_polymorphic_type = Conversions::ConvertToPolymorphicType.call(Models::Group)
        user_polymorphic_type = Conversions::ConvertToPolymorphicType.call(User)
        actor = Conversions::ConvertToProcessingActor.call(user)

        if actor.proxy_for_type.to_s == user_polymorphic_type.to_s
          user_constraints = actor_table[:proxy_for_type].eq(user_polymorphic_type).and(actor_table[:proxy_for_id].eq(actor.proxy_for_id))

          group_constraints = actor_table[:proxy_for_type].eq(group_polymorphic_type).and(
            actor_table[:proxy_for_id].in(
              memb_table.project(memb_table[:group_id]).where(
                memb_table[:user_id].eq(actor.proxy_for_id)
              )
            )
          )

          # Because AND takes precedence over OR, this query works.
          # WHERE (a AND b OR c AND d) == WHERE (a AND b) OR (c AND d)
          Models::Processing::Actor.where(user_constraints.or(group_constraints))
        elsif actor.proxy_for_type.to_s == group_polymorphic_type.to_s
          group_constraints = actor_table[:proxy_for_type].eq(group_polymorphic_type).and(actor_table[:proxy_for_id].eq(actor.proxy_for_id))
          Models::Processing::Actor.where(group_constraints)
        end
      end

      # @api public
      #
      # This method crosses the boundary out of the processing subsystem to
      # return an ActiveRecord::Relation scope of the objects that are proxied
      # by the processing system. The returned scope will returng objects that
      # meet the following criteria:
      #
      # * Processing Entities of the given proxy_for_type
      # * Processing Entities in a state in which I have access to based on:
      #   - The entity specific responsibility
      #     - For which I've been assigned either as a group member or a user
      #   - The strategy specific responsibility
      #     - For which I've been assigned either as a group member or a user
      #
      # @param [User] user
      # @param proxy_for_type something that can be converted to a polymorphic
      #   type.
      # @param criteria [Sipity::Parameters::SearchCriteriaForWorksParameter]
      #
      # @return [ActiveRecord::Relation<proxy_for_types>]
      def scope_proxied_objects_for_the_user_and_proxy_for_type(criteria:)
        proxy_for_type = Conversions::ConvertToPolymorphicType.call(criteria.proxy_for_type)
        scope = scope_processing_entities_for_the_user_and_proxy_for_type(criteria: criteria)

        scope = proxy_for_type.where(
          proxy_for_type.arel_table[proxy_for_type.primary_key].in(scope.entity).or(
            proxy_for_type.arel_table[proxy_for_type.primary_key].in(scope.strategy)
          )
        )

        if criteria.order?
          scope = scope.order(criteria.order)
        end

        if criteria.page?
          scope = scope.page(criteria.page)
          scope = scope.per(criteria.per) if criteria.per?
        end
        scope
      end

      PermissionScope = Struct.new(:entity, :strategy)
      private_constant :PermissionScope

      # @api private
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Processing Entities of the given proxy_for_type
      # * Processing Entities in a state in which I have access to based on:
      #   - The entity specific responsibility
      #     - For which I've been assigned either as a group member or a user
      #   - The strategy specific responsibility
      #     - For which I've been assigned either as a group member or a user
      #
      # In other words, for the given user and the given proxy for type (i.e.
      # Models::Work), fetch all of the processing entities that I can, in some
      # way, access based on the processing state.
      #
      # @param criteria [Sipity::Parameters::SearchCriteriaForWorksParameter]
      #
      # @return [ActiveRecord::Relation<Models::Processing::Entity>]
      def scope_processing_entities_for_the_user_and_proxy_for_type(criteria:)
        proxy_for_type = Conversions::ConvertToPolymorphicType.call(criteria.proxy_for_type)

        entities = Models::Processing::Entity.arel_table
        strategy_state_actions = Models::Processing::StrategyStateAction.arel_table
        strategy_states = Models::Processing::StrategyState.arel_table
        strategy_state_action_permissions = Models::Processing::StrategyStateActionPermission.arel_table
        strategy_responsibilities = Models::Processing::StrategyResponsibility.arel_table
        entity_responsibilities = Models::Processing::EntitySpecificResponsibility.arel_table

        user_actor_scope = scope_processing_actors_for(user: criteria.user)
        user_actor_contraints = user_actor_scope.arel_table.project(
          user_actor_scope.arel_table[:id]
        ).where(user_actor_scope.arel.constraints)

        join_builder = lambda do |responsibility|
          entities.project(
            entities[:proxy_for_id]
          ).join(strategy_state_actions).on(
            strategy_state_actions[:originating_strategy_state_id].eq(entities[:strategy_state_id])
          ).join(strategy_state_action_permissions).on(
            strategy_state_action_permissions[:strategy_state_action_id].eq(strategy_state_actions[:id])
          ).join(strategy_states).on(
            strategy_states[:id].eq(strategy_state_actions[:originating_strategy_state_id])
          ).join(responsibility).on(
            responsibility[:strategy_role_id].eq(strategy_state_action_permissions[:strategy_role_id])
          )
        end

        where_builder = lambda do |responsibility|
          returning = entities[:proxy_for_type].eq(proxy_for_type).and(
            responsibility[:actor_id].in(user_actor_contraints)
          )
          if criteria.processing_state?
            returning = returning.and(
              entities[:strategy_state_id].in(
                strategy_states.project(strategy_states[:id]).where(
                  strategy_states[:name].eq(criteria.processing_state)
                )
              )
            )
          end

          # NOTE: This assumes we are filtering on a Sipity::Models::Work
          if criteria.q?
            sipity_works = Models::Work.arel_table
            sipity_attributes = Models::AdditionalAttribute.arel_table
            returning = returning.and(
              entities[:proxy_for_id].in(
                # Ensuring that objects without attributes are also queried.
                sipity_works.project(sipity_works[:id]).join(sipity_attributes, Arel::Nodes::OuterJoin).on(
                  sipity_works[:id].eq(sipity_attributes[:work_id])
                ).where(
                  sipity_works[:title].matches("%#{criteria.q}%").or(
                    sipity_attributes[:value].matches("%#{criteria.q}%")
                  )
                )
              )
            )
          end

          # NOTE: This assumes we are filtering on a Sipity::Models::Work
          if criteria.submission_window?
            sipity_work_submissions = Models::WorkSubmission.arel_table
            submission_windows = Models::SubmissionWindow.arel_table
            returning = returning.and(
              entities[:proxy_for_id].in(
                sipity_work_submissions.project(sipity_work_submissions[:work_id]).join(submission_windows).on(
                  submission_windows[:id].eq(sipity_work_submissions[:submission_window_id])
                ).where(
                  submission_windows[:slug].eq(PowerConverter.convert(criteria.submission_window, to: :slug))
                )
              )
            )
          end
          returning
        end

        entity_specific_joins = join_builder.call(entity_responsibilities)
        strategy_specific_joins = join_builder.call(strategy_responsibilities)

        entity_specific_where = where_builder.call(entity_responsibilities).and(
          entities[:id].eq(entity_responsibilities[:entity_id])
        )
        strategy_specific_where = where_builder.call(strategy_responsibilities)

        PermissionScope.new(
          entity_specific_joins.where(entity_specific_where),
          strategy_specific_joins.where(strategy_specific_where)
        )
      end
      private :scope_processing_entities_for_the_user_and_proxy_for_type

      # @api public
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Users that are directly associated with the given entity through on or
      #   more of the given roles
      # * Users that are indirectly associated with the given entity by group
      #   and role.
      #
      # @param roles [Sipity::Models::Role]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<User>]
      def scope_users_for_entity_and_roles(entity:, roles:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        role_ids = Array.wrap(roles).map { |role| Conversions::ConvertToRole.call(role).id }
        group_polymorphic_type = Conversions::ConvertToPolymorphicType.call(Models::Group)
        user_polymorphic_type = Conversions::ConvertToPolymorphicType.call(User)

        strategy_roles = Models::Processing::StrategyRole.arel_table
        strategy_responsibilities = Models::Processing::StrategyResponsibility.arel_table
        entity_responsibilities = Models::Processing::EntitySpecificResponsibility.arel_table
        user_table = User.arel_table
        actor_table = Models::Processing::Actor.arel_table
        memb_table = Models::GroupMembership.arel_table

        strategy_role_id_subquery = strategy_roles.project(strategy_roles[:id]).where(
          strategy_roles[:role_id].in(role_ids)
        )

        strategy_actor_id_subquery = strategy_responsibilities.project(strategy_responsibilities[:actor_id]).where(
          strategy_responsibilities[:strategy_role_id].in(strategy_role_id_subquery)
        )

        entity_actor_id_subquery = entity_responsibilities.project(entity_responsibilities[:actor_id]).where(
          entity_responsibilities[:strategy_role_id].in(strategy_role_id_subquery).
          and(entity_responsibilities[:entity_id].eq(entity.id))
        )

        sub_query_for_user = actor_table.project(actor_table[:proxy_for_id]).where(
          actor_table[:id].in(strategy_actor_id_subquery).
          or(actor_table[:id].in(entity_actor_id_subquery))
        ).where(
          actor_table[:proxy_for_type].eq(user_polymorphic_type)
        )

        sub_query_for_user_via_group = memb_table.project(memb_table[:user_id]).where(
          memb_table[:group_id].in(
            actor_table.project(actor_table[:proxy_for_id]).where(
              actor_table[:id].in(strategy_actor_id_subquery).
              or(actor_table[:id].in(entity_actor_id_subquery))
            ).where(
              actor_table[:proxy_for_type].eq(group_polymorphic_type)
            )
          )
        )

        User.where(
          user_table[:id].in(sub_query_for_user).
          or(user_table[:id].in(sub_query_for_user_via_group))
        )
      end

      def user_emails_for_entity_and_roles(entity:, roles:)
        scope_users_for_entity_and_roles(entity: entity, roles: roles).pluck(:email)
      end

      # @api public
      #
      # For the given :user and :entity, return an ActiveRecord::Relation that,
      # if resolved, will be all of the assocated strategy roles for both the
      # strategy responsibilities and the entity specific responsibilities.
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyRole>]
      def scope_processing_strategy_roles_for_user_and_entity(user:, entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        strategy_scope = scope_processing_strategy_roles_for_user_and_strategy(user: user, strategy: entity.strategy)

        entity_specific_scope = scope_processing_strategy_roles_for_user_and_entity_specific(user: user, entity: entity)
        Models::Processing::StrategyRole.where(
          strategy_scope.arel.constraints.reduce.or(entity_specific_scope.arel.constraints.reduce)
        )
      end

      # @api private
      #
      # For the given :user and :strategy, return an ActiveRecord::Relation that,
      # if resolved, will be all of the assocated strategy roles that are
      # assigned to directly to the strategy.
      #
      # @param user [User]
      # @param strategy [Processing::Strategy]
      # @return [ActiveRecord::Relation<Models::Processing::StrategyRole>]
      def scope_processing_strategy_roles_for_user_and_strategy(user:, strategy:)
        responsibility_table = Models::Processing::StrategyResponsibility.arel_table
        strategy_role_table = Models::Processing::StrategyRole.arel_table

        actor_constraints = scope_processing_actors_for(user: user)
        strategy_role_subquery = strategy_role_table[:id].in(
          responsibility_table.project(responsibility_table[:strategy_role_id]).
          where(
            responsibility_table[:actor_id].in(
              actor_constraints.arel_table.project(
                actor_constraints.arel_table[:id]
              ).where(actor_constraints.arel.constraints)
            )
          )
        )

        Models::Processing::StrategyRole.where(
          strategy_role_table[:strategy_id].eq(strategy.id).and(strategy_role_subquery)
        )
      end

      # @api private
      #
      # For the given :user and :entity, return an ActiveRecord::Relation that,
      # if resolved, will be all of the assocated strategy roles that are
      # assigned to specifically to the entity (and not the parent strategy).
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyRole>]
      def scope_processing_strategy_roles_for_user_and_entity_specific(user:, entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actor_scope = scope_processing_actors_for(user: user)
        specific_resp_table = Models::Processing::EntitySpecificResponsibility.arel_table
        strategy_role_table = Models::Processing::StrategyRole.arel_table

        Models::Processing::StrategyRole.where(
          strategy_role_table[:id].in(
            specific_resp_table.project(specific_resp_table[:strategy_role_id]).
            where(
              specific_resp_table[:actor_id].in(
                actor_scope.arel_table.project(
                  actor_scope.arel_table[:id]
                ).where(
                  actor_scope.arel.constraints.reduce.and(specific_resp_table[:entity_id].eq(entity.id))
                )
              )
            )
          )
        )
      end

      # @api private
      #
      # For the given :user and :entity, return an ActiveRecord::Relation,
      # that if resolved, will be collection of
      # Sipity::Models::Processing::StrategyStateAction object to which the user has
      # permission to do something.
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * The actions are available for the given entity's current state
      # * The actions are available for the given user based on their role.
      #   Either:
      #   - Directly via an actor associated with a user
      #   - Indirectly via an actor associated with a group
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyStateAction>]
      def scope_permitted_entity_strategy_state_actions(user:, entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        strategy_state_actions = Models::Processing::StrategyStateAction
        permissions = Models::Processing::StrategyStateActionPermission
        role_scope = scope_processing_strategy_roles_for_user_and_entity(user: user, entity: entity)

        strategy_state_actions.where(
          strategy_state_actions.arel_table[:originating_strategy_state_id].eq(entity.strategy_state_id).and(
            strategy_state_actions.arel_table[:id].in(
              permissions.arel_table.project(
                permissions.arel_table[:strategy_state_action_id]
              ).where(
                permissions.arel_table[:strategy_role_id].in(
                  role_scope.arel_table.project(role_scope.arel_table[:id]).where(
                    role_scope.arel.constraints.reduce
                  )
                )
              )
            )
          )
        )
      end
      private :scope_permitted_entity_strategy_state_actions

      # @api private
      #
      # For the given :entity return an ActiveRecord::Relation that when
      # resolved will be only the strategy actions that:
      #
      # * Have prerequisites
      # * And all of those prerequisites have been completed
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_strategy_actions_with_completed_prerequisites(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        action_prereqs = Models::Processing::StrategyActionPrerequisite
        actions_that_occurred = scope_statetegy_actions_that_have_occurred(entity: entity)
        completed_guarded_actions_subquery = action_prereqs.arel_table.project(
          action_prereqs.arel_table[:guarded_strategy_action_id]
        ).where(
          action_prereqs.arel_table[:prerequisite_strategy_action_id].in(
            actions_that_occurred.arel_table.project(actions_that_occurred.arel_table[:id]).
            where(actions_that_occurred.arel.constraints.reduce)
          )
        )
        actions.where(
          actions.arel_table[:strategy_id].eq(entity.strategy_id).
          and(actions.arel_table[:id].in(completed_guarded_actions_subquery))
        )
      end

      # @api private
      #
      # For the given :entity return an ActiveRecord::Relation that when
      # resolved will be only the strategy actions that:
      #
      # * Has at least one prerequisite
      # * And at least one of those prerequisites is incomplete
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param pluck a list of column names to pluck from the query
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      # @return [Array] if a pluck is given
      def scope_strategy_actions_with_incomplete_prerequisites(entity:, pluck: nil)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        prerequisites = Models::Processing::StrategyActionPrerequisite.arel_table
        registers = Models::Processing::EntityActionRegister.arel_table

        incomplete_prerequisites_subquery = prerequisites.project(prerequisites[:guarded_strategy_action_id]).join(
          registers, Arel::Nodes::OuterJoin
        ).on(
          registers[:entity_id].eq(entity.id).and(
            registers[:strategy_action_id].eq(prerequisites[:prerequisite_strategy_action_id])
          )
        ).where(registers[:strategy_action_id].eq(nil))

        unplucked = actions.where(
          actions.arel_table[:strategy_id].eq(entity.strategy_id).and(
            actions.arel_table[:id].in(incomplete_prerequisites_subquery)
          )
        )
        return unplucked unless pluck.present?
        unplucked.pluck(pluck)
      end

      # @api private
      #
      # For the given :entity, return an ActiveRecord::Relation, that if
      # resolved, that is only the strategy actions that have no prerequisites.
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_strategy_actions_without_prerequisites(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        action_prereqs = Models::Processing::StrategyActionPrerequisite

        actions.where(
          actions.arel_table[:strategy_id].eq(entity.strategy_id).
          and(
            actions.arel_table[:id].not_in(
              action_prereqs.arel_table.project(
                action_prereqs.arel_table[:guarded_strategy_action_id]
              )
            )
          )
        )
      end

      # @api public
      #
      # For the given :entity return an ActiveRecord::Relation that when
      # resolved will be only the strategy actions that:
      #
      # * Are available for the entity's strategy_state
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_strategy_actions_for_current_state(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        state_actions_table = Models::Processing::StrategyStateAction.arel_table
        actions.where(
          actions.arel_table[:id].in(
            state_actions_table.project(state_actions_table[:strategy_action_id]).
            where(state_actions_table[:originating_strategy_state_id].eq(entity.strategy_state_id))
          )
        )
      end

      # @api public
      #
      # For the given :entity return an ActiveRecord::Relation that when
      # resolved will be only the strategy actions that:
      #
      # * Are prerequisites for one or more other actions
      # * Are actions associated with the entity's processing strategy
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param pluck a list of column names to pluck from the query
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>] if no pluck is given
      # @return [Array] if a pluck is given
      def scope_strategy_actions_that_are_prerequisites(entity:, pluck: nil)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        prerequisite_actions = Models::Processing::StrategyActionPrerequisite.arel_table
        unplucked = actions.where(
          actions.arel_table[:id].in(
            prerequisite_actions.project(prerequisite_actions[:prerequisite_strategy_action_id])
          ).and(actions.arel_table[:strategy_id].eq(entity.strategy_id))
        )
        return unplucked unless pluck.present?
        unplucked.pluck(pluck)
      end

      # @api private
      #
      # For the given :entity, return an ActiveRecord::Relation, that if
      # resolved, that is only the strategy actions that have occurred.
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param pluck a list of column names to pluck from the query
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>] if no pluck is given
      # @return [Array] if a pluck is given
      def scope_statetegy_actions_that_have_occurred(entity:, pluck: nil)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        register = Models::Processing::EntityActionRegister

        unplucked = actions.where(
          actions.arel_table[:strategy_id].eq(entity.strategy_id).
          and(
            actions.arel_table[:id].in(
              register.arel_table.project(register.arel_table[:strategy_action_id]).
              where(register.arel_table[:entity_id].eq(entity.id))
            )
          )
        )
        return unplucked unless pluck.present?
        unplucked.pluck(pluck)
      end

      # @api private
      #
      # For the given :entity, return an ActiveRecord::Relation, that
      # if resolved, that lists all of the actions available for the entity and
      # its current state.
      #
      # * All actions that are associated with actions that do not have prerequsites
      # * All actions that have prerequisites and all of those prerequisites are complete
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_strategy_actions_available_for_current_state(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        strategy_actions_without_prerequisites = scope_strategy_actions_without_prerequisites(entity: entity)
        strategy_actions_with_completed_prerequisites = scope_strategy_actions_with_completed_prerequisites(entity: entity)
        strategy_actions_for_current_state = scope_strategy_actions_for_current_state(entity: entity)
        actions = Models::Processing::StrategyAction
        actions.where(
          strategy_actions_without_prerequisites.constraints.reduce.and(
            strategy_actions_for_current_state.constraints.reduce
          ).or(
            strategy_actions_with_completed_prerequisites.constraints.reduce.and(
              strategy_actions_for_current_state.constraints.reduce
            )
          )
        )
      end
    end
  end
end
