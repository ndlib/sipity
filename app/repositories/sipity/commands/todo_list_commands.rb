module Sipity
  # :nodoc:
  module Commands
    # Responsible for interaction with the todo list.
    # TODO: Rename to ProcessingCommands
    module TodoListCommands
      def register_action_taken_on_entity(entity:, action:, requested_by:, **keywords)
        Services::ActionTakenOnEntity.register(
          entity: entity, action: action, requested_by: requested_by, **{ on_behalf_of: requested_by, repository: self }.merge(keywords)
        )
      end

      def unregister_action_taken_on_entity(entity:, action:, requested_by:, **keywords)
        Services::ActionTakenOnEntity.unregister(
          entity: entity, action: action, requested_by: requested_by, **{ on_behalf_of: requested_by, repository: self }.merge(keywords)
        )
      end

      def unregister_action_taken_on_entity_by_anyone(entity:, action:, requested_by:, **keywords)
        Services::ActionTakenOnEntity.unregister_entity_action(
          entity: entity, action: action, requested_by: requested_by, **{ repository: self }.merge(keywords)
        )
      end

      # @api public
      #
      # Responsible for capturing a :comment made by a given :commenter on a
      # given :entity as part of a given :action.
      #
      # @param entity <can be converted to a Processing::Entity>
      # @param commenter <can be converted to a Processing::Actor>
      # @param action <can be converted to a Processing::StrategyAction>
      # @param comment <String>
      #
      # @return Models::Processing::Comment
      def record_processing_comment(entity:, commenter:, action:, comment:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actor = Conversions::ConvertToProcessingActor.call(commenter)
        action = Conversions::ConvertToProcessingAction.call(action, scope: entity)

        # Opting for IDs because I want my unit tests to not require all of the
        # collaborating models to be built.
        Models::Processing::Comment.create!(
          entity_id: entity.id,
          actor_id: actor.id,
          originating_strategy_action_id: action.id,
          originating_strategy_state_id: entity.strategy_state.id,
          comment: comment
        )
      end
    end
  end
end
