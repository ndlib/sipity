require 'dry/validation/schema'
require 'sipity/data_generators/strategy_permission_schema'
require 'sipity/data_generators/processing_action_schema'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work types.
    WorkTypeSchema = Dry::Validation.Schema do
      required(:work_types).each do
        required(:name).filled(:str?)
        required(:actions).each { schema(ProcessingActionSchema) }
        optional(:strategy_permissions).each { schema(StrategyPermissionSchema) }
        optional(:action_analogues).each do
          schema do
            required(:action).filled(:str?)
            required(:analogous_to).filled(:str?)
          end
        end
        optional(:state_emails).each do
          schema do
            required(:state).filled(:str?)
            required(:emails).each { schema(EmailSchema) }
            required(:reason) do
              included_in?([
                Parameters::NotificationContextParameter::REASON_ENTERED_STATE,
                Parameters::NotificationContextParameter::REASON_PROCESSING_HOOK_TRIGGERED
              ])
            end
          end
        end
      end
    end
  end
end
