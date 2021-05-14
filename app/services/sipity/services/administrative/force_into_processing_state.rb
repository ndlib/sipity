module Sipity
  module Services
    module Administrative
      # @api private
      #
      # A utility service that forces the entity into a given state.
      #
      # It circumvents:
      #   * authentication
      #   * authorization
      #   * state transition calls
      #   * processing hook calls
      class ForceIntoProcessingState
        # @api public
        #
        # @param entity [#to_processing_entity] An entity that can be coerced into a Models::Processing::Entity
        # @param state [#to_strategy_state] An object that can be coerced into a Models::Processing::StrategyState within the strategy scope
        #        of given entity
        def self.call(entity:, state:, **keywords)
          new(entity: entity, state: state, **keywords).call
        end

        def initialize(entity:, state:, clear_actions: true, repository: default_repository)
          self.entity = entity
          self.state = state
          self.clear_actions = clear_actions
          self.repository = repository
        end

        def call
          entity.update_columns(strategy_state_id: state.id)
          repository.destroy_existing_registered_state_changing_actions_for(entity: entity, strategy_state: state) if clear_actions?
          return true
        end

        private

        attr_reader :entity, :state, :clear_actions
        attr_accessor :repository

        def default_repository
          CommandRepository.new
        end

        def clear_actions=(input)
          @clear_actions = PowerConverter.convert(input, to: :boolean)
        end

        alias clear_actions? clear_actions

        def entity=(input)
          @entity = Conversions::ConvertToProcessingEntity.call(input)
        end

        def state=(input)
          @state = PowerConverter.convert(input, to: :strategy_state, scope: entity.strategy)
        end
      end
    end
  end
end
