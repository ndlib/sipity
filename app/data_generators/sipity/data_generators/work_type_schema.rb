require 'sipity/data_generators/strategy_permission_schema'
require 'sipity/data_generators/processing_action_schema'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work types.
    WorkTypeSchema = Dry::Schema.JSON do
      required(:work_types).value(:array).each do
        schema do
          # The given and unique <name> of the workflow
          required(:name).filled(:str?)

          # What are all the <actions> associated with this state machine. Note,
          # the actions encode what the various available states are.
          required(:actions).value(:array).each { schema(ProcessingActionSchema) }

          # The <strategy_permissions> defiens the permissions that apply to all
          # entities that use this workflow.
          optional(:strategy_permissions).value(:array).each { schema(StrategyPermissionSchema) }

          # An odd-duck, but crucial for proxy approval, the <action_analogues>
          # exposes a means for someone to approve on behalf of another person
          # and treat that proxy approval as though the actual person approved
          # and took the action. In most cases, you can ignore this.
          optional(:action_analogues).value(:array).each do
            schema do
              required(:action).filled(:str?)
              required(:analogous_to).filled(:str?)
            end
          end

          # When you change <state> for a the given <reason>, trigger send
          # <emails> that are outlined in the <state_emails> section
          optional(:state_emails).value(:array).each do
            schema do
              required(:state).filled(:str?)
              required(:emails).value(:array).each { schema(EmailSchema) }
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
end
