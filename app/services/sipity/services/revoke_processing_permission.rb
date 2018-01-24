module Sipity
  module Services
    # Service object that handles the business logic of revoking permissions.
    # @see Sipity::Services::GrantProcessingPermission
    class RevokeProcessingPermission
      # @api public
      #
      # Responsible for revoking the given actor's role assignment from the given entity, regardless of whether the actor is assigned
      # the role to the entity.
      #
      # @param entity [#to_processing_entity]
      # @param actor [#to_processing_actor]
      # @param actor [#to_role]
      # @return True
      def self.call(entity:, actor:, role:)
        new(entity: entity, actor: actor, role: role).call
      end

      def initialize(entity:, actor:, role:)
        self.entity = entity
        self.actor = actor
        self.role = role
      end
      attr_reader :entity, :actor, :role

      def call
        with_valid_strategy_role do |strategy_role|
          destroy_entity_specific_responsibility(strategy_role: strategy_role) unless strategy_role_responsibility_exists?
        end
      end

      private

      def with_valid_strategy_role
        strategy_role = Models::Processing::StrategyRole.find_by!(strategy_id: entity.strategy_id, role_id: role.id)
        yield(strategy_role)
      rescue ActiveRecord::RecordNotFound
        true
      end

      def destroy_entity_specific_responsibility(strategy_role:)
        Models::Processing::EntitySpecificResponsibility.where(
          strategy_role_id: strategy_role.id, entity_id: entity.id, actor_id: actor.id
        ).destroy_all
      end

      def strategy_role_responsibility_exists?
        Models::Processing::StrategyRole.where(
          role_id: role.id, strategy_id: entity.strategy_id
        ).joins(:strategy_responsibilities).any?
      end

      include Conversions::ConvertToProcessingEntity
      def entity=(object)
        @entity = convert_to_processing_entity(object)
      end

      include Conversions::ConvertToProcessingActor
      def actor=(object)
        @actor = convert_to_processing_actor(object)
      end

      include Conversions::ConvertToRole
      def role=(object)
        @role = convert_to_role(object)
      end
    end
  end
end
