module Sipity
  module Models
    module Processing
      # A named action that, during the processing of an entity, may be taken.
      class StrategyNevent < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_nevents'
        belongs_to :strategy
        belongs_to :resulting_strategy_state, class_name: 'StrategyState'

        has_many :entity_nevent_registers, dependent: :destroy

        has_many :strategy_events, dependent: :destroy
        has_many :guarding_strategy_nevent_prerequisites,
          dependent: :destroy,
          foreign_key: :prerequisite_strategy_nevent_id,
          class_name: 'Sipity::Models::Processing::StrategyNeventPrerequisite'

        has_many :requiring_strategy_nevent_prerequisites,
          dependent: :destroy,
          foreign_key: :guarded_strategy_nevent_id,
          class_name: 'Sipity::Models::Processing::StrategyNeventPrerequisite'

        has_many :guards_these_strategy_nevents,
          through: :guarding_strategy_nevent_prerequisites,
          class_name: 'Sipity::Models::Processing::StrategyNevent'

        has_many :requires_these_strategy_nevents,
          through: :requiring_strategy_nevent_prerequisites,
          class_name: 'Sipity::Models::Processing::StrategyNevent'
      end
    end
  end
end
