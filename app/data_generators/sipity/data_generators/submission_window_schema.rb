require 'sipity/data_generators/strategy_permission_schema'
require 'sipity/data_generators/processing_action_schema'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work types.
    SubmissionWindowSchema = Dry::Schema.JSON do
      required(:submission_windows).value(:array).each do
        schema do
          required(:attributes).schema do
            required(:slug).filled(:str?)
            optional(:open_for_starting_submissions_at).filled(format?: /\A\d{4}-\d{2}-\d{2}\Z/)
          end
          required(:actions).value(:array).each { schema(ProcessingActionSchema) }
          optional(:strategy_permissions).value(:array).each { schema(StrategyPermissionSchema) }
          required(:work_type_config_paths).value(:array).each(:str?)
        end
      end
    end
  end
end
