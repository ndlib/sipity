require 'dry/validation/schema'
require 'sipity/data_generators/strategy_permission_schema'
require 'sipity/data_generators/processing_action_schema'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work areas.
    WorkAreaSchema = Dry::Validation.Schema do
      required(:work_areas).each do
        required(:attributes).schema do
          required(:name).filled(:str?)
          required(:slug).filled(:str?)
        end
        required(:actions).each { schema(ProcessingActionSchema) }
        optional(:strategy_permissions).each { schema(StrategyPermissionSchema) }
        # Note: I'm keeping required as, at this point, I'm unable to tweak to use filled
        optional(:submission_window_config_paths).required { str? | array? { each { str? } } }
      end
    end
  end
end
