require 'dry/validation/schema'
require 'sipity/data_generators/strategy_permission_schema'
require 'sipity/data_generators/processing_action_schema'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work types.
    WorkTypeSchema = Dry::Validation.Schema do
      key(:work_types).each do
        key(:name).required(:str?)
        key(:actions).each { schema(ProcessingActionSchema) }
        optional(:strategy_permissions).each { schema(StrategyPermissionSchema) }
        optional(:action_analogues).each do
          schema do
            key(:action).required(:str?)
            key(:analogous_to).required(:str?)
          end
        end
        optional(:state_emails).each do
          schema do
            key(:state).required(:str?)
            key(:emails).each { schema(EmailSchema) }
            key(:reason) do
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
