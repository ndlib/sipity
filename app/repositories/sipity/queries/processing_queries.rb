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
      include Conversions::ConvertToProcessingEntity
      include Conversions::ConvertToPolymorphicType
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
      def scope_permitted_strategy_state_actions_available_for_current_state(user:, entity:)
        strategy_actions_scope = scope_strategy_state_actions_available_for_current_state(entity: entity)
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
      # * All of the Processing Actors directly associated with the given :user
      # * All of the Processing Actors indirectly associated with the given
      #   :user through the user's group membership.
      #
      # @param user [User]
      # @return ActiveRecord::Relation<Models::Processing::Actor>
      def scope_processing_actors_for(user:)
        memb_table = Models::GroupMembership.arel_table
        actor_table = Models::Processing::Actor.arel_table

        group_polymorphic_type = convert_to_polymorphic_type(Models::Group)
        user_polymorphic_type = convert_to_polymorphic_type(user)

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
      # For the given :user and :entity, return an ActiveRecord::Relation that,
      # if resolved, will be all of the assocated strategy roles for both the
      # strategy responsibilities and the entity specific responsibilities.
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return ActiveRecord::Relation<Models::Processing::StrategyRole>
      def scope_processing_strategy_roles_for_user_and_entity(user:, entity:)
        entity = convert_to_processing_entity(entity)
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
        entity = convert_to_processing_entity(entity)
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
                actor_scope.arel.constraints.reduce.and(specific_resp_table[:entity_id].eq(entity.id)))
              )
            )
          )
        )
      end

      # For the given :user and :entity, return an ActiveRecord::Relation,
      # that if resolved, will be collection of
      # Sipity::Models::Processing::StrategyStateAction object to which the user has
      # permission to do something.
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return ActiveRecord::Relation<Models::Processing::StrategyStateAction>
      def scope_permitted_entity_strategy_state_actions(user:, entity:)
        entity = convert_to_processing_entity(entity)
        strategy_state_actions = Models::Processing::StrategyStateAction
        permissions = Models::Processing::StrategyStateActionPermission
        role_scope = scope_processing_strategy_roles_for_user_and_entity(user: user, entity: entity)
        strategy_state_actions.where(
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
      end

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
        entity = convert_to_processing_entity(entity)
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
      # For the given :entity, return an ActiveRecord::Relation, that if
      # resolved, that is only the strategy actions that have no prerequisites.
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return ActiveRecord::Relation<Models::Processing::StrategyAction>
      def scope_strategy_actions_without_prerequisites(entity:)
        entity = convert_to_processing_entity(entity)
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
        entity = convert_to_processing_entity(entity)
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
        entity = convert_to_processing_entity(entity)
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
        entity = convert_to_processing_entity(entity)
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
      # @return ActiveRecord::Relation<Models::Processing::StrategyStateAction>
      def scope_strategy_state_actions_available_for_current_state(entity:)
        entity = convert_to_processing_entity(entity)
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
