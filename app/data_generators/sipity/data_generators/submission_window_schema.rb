require 'dry/validation/schema'
require 'sipity/data_generators/strategy_permission_schema'
require 'sipity/data_generators/processing_action_schema'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work types.
    SubmissionWindowSchema = Dry::Validation.Schema do
      required(:submission_windows).each do
        required(:attributes).schema do
          required(:slug).filled(:str?)
          optional(:open_for_starting_submissions_at).filled(format?: /\A\d{4}-\d{2}-\d{2}\Z/)
        end
        required(:actions).each { schema(ProcessingActionSchema) }
        optional(:strategy_permissions).each { schema(StrategyPermissionSchema) }
        # Note: I'm keeping required as, at this point, I'm unable to tweak to use filled
        required(:work_type_config_paths).required { str? | array? { each { str? } } }
      end
    end
  end
end
