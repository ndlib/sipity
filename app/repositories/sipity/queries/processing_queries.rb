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
      # Is the user authorized to take the processing action on the given
      # entity?
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param action an object that can be converted into a Sipity::Models::Processing::StrategyAction#name
      # @return Boolean
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
      # @return ActiveRecord::Relation<User>
      def users_that_have_taken_the_action_on_the_entity(entity:, action:)
        users = User.arel_table
        group_memberships = Models::GroupMembership.arel_table

        User.where(
          users[:id].in(
            action_registers_subquery_builder(
              poly_type: User, entity: entity, action: action
            )
          ).or(
            users[:id].in(
              group_memberships.project(group_memberships[:user_id]).where(
                group_memberships[:group_id].in(
                  action_registers_subquery_builder(
                    poly_type: Sipity::Models::Group, entity: entity, action: action
                  )
                )
              )
            )
          )
        )
      end

      def action_registers_subquery_builder(poly_type:, entity:, action:)
        actors = Models::Processing::Actor.arel_table
        action_registers = Models::Processing::EntityActionRegister.arel_table
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        action = Conversions::ConvertToProcessingAction.call(action, scope: entity)
        poly_type = Conversions::ConvertToPolymorphicType.call(poly_type)

        actors.project(actors[:proxy_for_id]).where(
          actors[:proxy_for_type].eq(poly_type)
        ).join(action_registers).on(
          action_registers[:on_behalf_of_actor_id].eq(actors[:id])
        ).where(
          action_registers[:strategy_action_id].eq(action.id).
          and(action_registers[:entity_id].eq(entity.id))
        )
      end
      private :action_registers_subquery_builder

      # @api private
      def non_user_collaborators_that_have_taken_the_action_on_the_entity(entity:, action:)
        Models::Collaborator.where(
          Models::Collaborator.arel_table[:id].in(
            action_registers_subquery_builder(poly_type: Models::Collaborator, entity: entity, action: action)
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
      # @return ActiveRecord::Relation<User>
      def collaborators_that_have_taken_the_action_on_the_entity(entity:, action:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        collaborators = Models::Collaborator.arel_table
        users = User.arel_table
        users_scope = users_that_have_taken_the_action_on_the_entity(entity: entity, action: action)
        non_user_collaborator_scope = non_user_collaborators_that_have_taken_the_action_on_the_entity(entity: entity, action: action)

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
      # @return ActiveRecord::Relation<Models::Processing::StrategyAction>
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
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return ActiveRecord::Relation<Models::Processing::StrategyAction>
      def scope_permitted_entity_strategy_actions_for_current_state(user:, entity:)
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

      # @api public
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * All of the Processing Actors directly associated with the given :user
      # * All of the Processing Actors indirectly associated with the given
      #   :user through the user's group membership.
      #
      # @param user [User]
      # @return ActiveRecord::Relation<Models::Processing::Actor>
      def scope_processing_actors_for(user:)
        return Models::Processing::Actor.where('1 = 0') unless user.present?

        memb_table = Models::GroupMembership.arel_table
        actor_table = Models::Processing::Actor.arel_table

        group_polymorphic_type = Conversions::ConvertToPolymorphicType.call(Models::Group)
        user_polymorphic_type = Conversions::ConvertToPolymorphicType.call(user)

        user_constraints = actor_table[:proxy_for_type].eq(user_polymorphic_type).and(actor_table[:proxy_for_id].eq(user.id))

        group_constraints = actor_table[:proxy_for_type].eq(group_polymorphic_type).and(
          actor_table[:proxy_for_id].in(
            memb_table.project(memb_table[:group_id]).where(
              memb_table[:user_id].eq(user.id)
            )
          )
        )

        # Because AND takes precedence over OR, this query works.
        # WHERE (a AND b OR c AND d) == WHERE (a AND b) OR (c AND d)
        Models::Processing::Actor.where(user_constraints.or(group_constraints))
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
      # @param [Hash] filter
      # @option filter [String] :processing_state - Limit the returned objects
      #   to those objects that are in the named :processing_state
      #
      # @return ActiveRecord::Relation<proxy_for_types>
      def scope_proxied_objects_for_the_user_and_proxy_for_type(user:, proxy_for_type:, filter: {})
        proxy_for_type = Conversions::ConvertToPolymorphicType.call(proxy_for_type)
        processing_entities_scope = scope_processing_entities_for_the_user_and_proxy_for_type(
          user: user, proxy_for_type: proxy_for_type, filter: filter
        )

        proxy_for_type.where(
          proxy_for_type.arel_table[proxy_for_type.primary_key].in(
            processing_entities_scope.arel_table.project(:proxy_for_id).where(
              processing_entities_scope.arel.constraints.reduce
            )
          )
        )
      end

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
      # @param [User] user
      # @param proxy_for_type something that can be converted to a polymorphic
      #   type.
      # @param [Hash] filter
      # @option filter [String] :processing_state - Limit the returned objects
      #   to those objects that are in the named :processing_state
      #
      #
      # @return ActiveRecord::Relation<Models::Processing::Entity>
      def scope_processing_entities_for_the_user_and_proxy_for_type(user:, proxy_for_type:, filter: {})
        proxy_for_type = Conversions::ConvertToPolymorphicType.call(proxy_for_type)

        entities = Models::Processing::Entity.arel_table
        strategy_state_actions = Models::Processing::StrategyStateAction.arel_table
        strategy_states = Models::Processing::StrategyState.arel_table
        strategy_state_action_permissions = Models::Processing::StrategyStateActionPermission.arel_table
        strategy_roles = Models::Processing::StrategyRole.arel_table
        strategy_responsibilities = Models::Processing::StrategyResponsibility.arel_table
        entity_responsibilities = Models::Processing::EntitySpecificResponsibility.arel_table

        user_actor_scope = scope_processing_actors_for(user: user)
        user_actor_contraints = user_actor_scope.arel_table.project(
          user_actor_scope.arel_table[:id]
        ).where(user_actor_scope.arel.constraints)

        available_strategy_state_subqueries = strategy_state_actions.project(
          strategy_state_actions[:originating_strategy_state_id]
        ).join(strategy_state_action_permissions).on(
          strategy_state_action_permissions[:strategy_state_action_id].eq(strategy_state_actions[:id])
        ).join(strategy_states).on(
          strategy_states[:id].eq(strategy_state_actions[:originating_strategy_state_id])
        ).join(strategy_roles).on(
          strategy_roles[:id].eq(strategy_state_action_permissions[:strategy_role_id])
        ).where(
          strategy_state_action_permissions[:strategy_role_id].in(
            strategy_responsibilities.project(
              strategy_responsibilities[:strategy_role_id]
            ).where(
              strategy_responsibilities[:actor_id].in(user_actor_contraints)
            )
          )
        )

        availble_entity_specific_subqueries = entity_responsibilities.project(
          entity_responsibilities[:entity_id]
        ).join(strategy_state_action_permissions).on(
          strategy_state_action_permissions[:strategy_role_id].eq(entity_responsibilities[:strategy_role_id])
        ).where(
          strategy_state_action_permissions[:strategy_role_id].in(
            entity_responsibilities.project(
              entity_responsibilities[:strategy_role_id]
            ).where(entity_responsibilities[:actor_id].in(user_actor_contraints))
          )
        )

        unfiltered_scope = Models::Processing::Entity.where(proxy_for_type: proxy_for_type).where(
          entities[:strategy_state_id].in(available_strategy_state_subqueries).or(
            entities[:id].in(availble_entity_specific_subqueries)
          )
        )
        processing_state = filter[:processing_state]
        return unfiltered_scope unless processing_state.present?

        unfiltered_scope.where(
          entities[:strategy_state_id].in(
            strategy_states.project(strategy_states[:id]).where(
              strategy_states[:name].eq(processing_state)
            )
          )
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
      # @param role [Sipity::Models::Role]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return ActiveRecord::Relation<User>
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
      module_function :scope_users_for_entity_and_roles
      public :scope_users_for_entity_and_roles

      # @api public
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Users that are directly proxied by one or more of the actors
      # * Users that are indirectly, by way of a group, proxy by one or more of
      #   the actors.
      #
      # @param Actors [Sipity::Models::Processing::ActorRole]
      # @return ActiveRecord::Relation<User>
      def scope_users_from_actors(actors:)
        user_table = User.arel_table
        actor_table = Models::Processing::Actor.arel_table
        memb_table = Models::GroupMembership.arel_table

        actor_ids = actors.map { |actor| Conversions::ConvertToProcessingActor.call(actor).id }

        group_polymorphic_type = Conversions::ConvertToPolymorphicType.call(Models::Group)
        user_polymorphic_type = Conversions::ConvertToPolymorphicType.call(User)

        sub_query_for_user = actor_table.project(actor_table[:proxy_for_id]).where(
          actor_table[:proxy_for_type].eq(user_polymorphic_type).
          and(actor_table[:id].in(actor_ids))
        )

        sub_query_for_user_via_group = memb_table.project(memb_table[:user_id]).where(
          memb_table[:user_id].in(
            actor_table.project(actor_table[:proxy_for_id]).where(
              actor_table[:proxy_for_type].eq(group_polymorphic_type).
              and(actor_table[:id].in(actor_ids))
            )
          )
        )
        User.where(
          user_table[:id].in(sub_query_for_user).
          or(user_table[:id].in(sub_query_for_user_via_group))
        )
      end

      # @api public
      #
      # For the given :user and :entity, return an ActiveRecord::Relation that,
      # if resolved, will be all of the assocated strategy roles for both the
      # strategy responsibilities and the entity specific responsibilities.
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return ActiveRecord::Relation<Models::Processing::StrategyRole>
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
      # @param entity [Processing::Strategy]
      # @return ActiveRecord::Relation<Models::Processing::StrategyRole>
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
      # @return ActiveRecord::Relation<Models::Processing::StrategyRole>
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
      # @return ActiveRecord::Relation<Models::Processing::StrategyStateAction>
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
      # @return ActiveRecord::Relation<Models::Processing::StrategyAction>
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
      # @return ActiveRecord::Relation<Models::Processing::StrategyAction>
      def scope_strategy_actions_with_incomplete_prerequisites(entity:)
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

        actions.where(
          actions.arel_table[:strategy_id].eq(entity.strategy_id).and(
            actions.arel_table[:id].in(incomplete_prerequisites_subquery)
          )
        )
      end

      # @api private
      #
      # For the given :entity, return an ActiveRecord::Relation, that if
      # resolved, that is only the strategy actions that have no prerequisites.
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return ActiveRecord::Relation<Models::Processing::StrategyAction>
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
      # @return ActiveRecord::Relation<Models::Processing::StrategyAction>
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
      # @return ActiveRecord::Relation<Models::Processing::StrategyAction>
      def scope_strategy_actions_that_are_prerequisites(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        prerequisite_actions = Models::Processing::StrategyActionPrerequisite.arel_table
        actions.where(
          actions.arel_table[:id].in(
            prerequisite_actions.project(prerequisite_actions[:prerequisite_strategy_action_id])
          ).and(actions.arel_table[:strategy_id].eq(entity.strategy_id))
        )
      end

      # @api private
      #
      # For the given :entity, return an ActiveRecord::Relation, that if
      # resolved, that is only the strategy actions that have occurred.
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return ActiveRecord::Relation<Models::Processing::StrategyAction>
      def scope_statetegy_actions_that_have_occurred(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        register = Models::Processing::EntityActionRegister

        actions.where(
          actions.arel_table[:strategy_id].eq(entity.strategy_id).
          and(
            actions.arel_table[:id].in(
              register.arel_table.project(register.arel_table[:strategy_action_id]).
              where(register.arel_table[:entity_id].eq(entity.id))
            )
          )
        )
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
      # @return ActiveRecord::Relation<Models::Processing::StrategyAction>
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
