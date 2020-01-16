module Sipity
  module Services
    # Responsible for revoking action permission
    class RevokeActionsForGivenRole
      # @api public
      #
      # For the given role and strategy, revoke all of the given actions that exist in the given strategy states
      #
      # @param role [#to_role] (see Sipity::Conversions::ConvertToRole)
      # @param strategy_id [#to_strategy_id] (see Sipity::Conversions::ConvertToProcessingStrategyId)
      # @param action_names [Array<#convert_to_processing_action_name>, #convert_to_processing_action_name]
      #                     (see Sipity::Conversions::ConvertToProcessingActionName)
      # @param strategy_state_names [Array<String>, String] (see Sipity::Conversions::ConvertToProcessingActionName)
      def self.call(role:, strategy_id:, action_names:, strategy_state_names:)
        new(role: role, strategy_id: strategy_id, action_names: action_names, strategy_state_names: strategy_state_names).call
      end

      # @api private
      def initialize(role:, strategy_id:, action_names:, strategy_state_names:)
        self.role = role
        self.strategy_id = strategy_id
        self.action_names = action_names
        self.strategy_state_names = strategy_state_names
        initialize_strategy_roles!
      end
      attr_reader :role, :strategy_id, :action_names, :strategy_state_names, :strategy_roles

      # @api private
      def call
        strategy_actions = Models::Processing::StrategyAction.where(strategy_id: strategy_id, name: action_names)
        strategy_states = Models::Processing::StrategyState.where(strategy_id: strategy_id, name: strategy_state_names)
        strategy_state_actions = Models::Processing::StrategyStateAction.where(
          originating_strategy_state: strategy_states, strategy_action: strategy_actions
        )
        permitted_state_actions = Models::Processing::StrategyStateActionPermission.where(
          strategy_state_action: strategy_state_actions, strategy_role: strategy_roles
        )
        permitted_state_actions.destroy_all
      end

      private

      def initialize_strategy_roles!
        @strategy_roles = Models::Processing::StrategyRole.where(strategy_id: strategy_id, role: role)
      end

      def strategy_state_names=(input)
        @strategy_state_names = Array.wrap(input)
      end

      include Conversions::ConvertToProcessingActionName
      def action_names=(input)
        @action_names = Array.wrap(input).map { |element| convert_to_processing_action_name(element) }
      end

      include Conversions::ConvertToRole
      def role=(object)
        @role = convert_to_role(object)
      end

      include Conversions::ConvertToProcessingStrategyId
      def strategy_id=(object)
        @strategy_id = convert_to_processing_strategy_id(object)
      end
    end
  end
end
