module Sipity
  module Models
    module Processing
      # A proxy for the entity that is being processed.
      # By using a proxy, we need not worry about polluting the proxy's concerns
      # with things related to processing.
      #
      # The goal is to keep this behavior separate, so that we can possibly
      # extract the information.
      class Entity < ActiveRecord::Base
        self.table_name = 'sipity_processing_entities'

        belongs_to :proxy_for, polymorphic: true
        belongs_to :strategy
        belongs_to :strategy_state

        has_many :entity_action_registers, dependent: :destroy
        has_many :entity_specific_responsibilities, dependent: :destroy

        has_many(
          :processing_comments,
          foreign_key: :entity_id,
          dependent: :destroy,
          class_name: 'Sipity::Models::Processing::Comment'
        )

        has_many(
          :administrative_scheduled_actions,
          dependent: :destroy,
          class_name: 'Sipity::Models::Processing::AdministrativeScheduledAction'
        )

        delegate :name, to: :strategy_state, prefix: :strategy_state
        delegate :name, to: :strategy, prefix: :strategy

        # TODO: This is a concession for the existing application
        alias_method :processing_state, :strategy_state_name
        # TODO: Concession for an interface
        alias_method :processing_strategy, :strategy
      end
    end
  end
end
