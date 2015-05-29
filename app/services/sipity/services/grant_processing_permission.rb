module Sipity
  module Services
    # Service object that handles the business logic of granting permission.
    class GrantProcessingPermission
      def self.call(entity:, actor:, role:)
        new(entity: entity, actor: actor, role: role).call
      end

      def initialize(entity:, actor:, role:)
        self.entity = entity
        self.actor = actor
        self.role = role
      end
      attr_reader :entity, :actor, :role

      delegate :strategy, to: :entity

      def call
        with_valid_strategy_role do |strategy_role|
          create_entity_specific_responsibility(strategy_role: strategy_role) unless strategy_role_responsibility_exists?
        end
      end

      private

      def with_valid_strategy_role
        strategy_role = Models::Processing::StrategyRole.where(strategy_id: strategy.id, role_id: role.id).first!
        yield(strategy_role)
      rescue ActiveRecord::RecordNotFound => e
        raise Exceptions::ValidProcessingStrategyRoleNotFoundError, e.message
      end

      def create_entity_specific_responsibility(strategy_role:)
        Models::Processing::EntitySpecificResponsibility.find_or_create_by!(
          strategy_role_id: strategy_role.id, entity_id: entity.id, actor_id: actor.id
        )
      end

      def strategy_role_responsibility_exists?
        Models::Processing::StrategyRole.where(
          role_id: role.id, strategy_id: strategy.id
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
