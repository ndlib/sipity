require 'sipity/data_generators/strategy_permission_schema'
require 'sipity/data_generators/processing_action_schema'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work areas.
    WorkAreaSchema = Dry::Schema.JSON do
      required(:work_areas).value(:array).each do
        schema do
          required(:attributes).schema do
            required(:name).filled(:str?)
            required(:slug).filled(:str?)
          end
          required(:actions).value(:array).each { schema(ProcessingActionSchema) }
          optional(:strategy_permissions).value(:array).each { schema(StrategyPermissionSchema) }
          optional(:submission_window_config_paths).value(:array).each(:str?)
        end
      end
    end
  end
end
