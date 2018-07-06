require 'dry/validation/schema'
require 'sipity/data_generators/email_schema'

module Sipity
  module DataGenerators
    ProcessingActionSchema = Dry::Validation.Schema do
      # The <name> of the action that you will take. This is a unique name
      # within the state machine.
      required(:name).filled(:str?)

      # When taking this action, will this action transition the state? If so,
      # specify what state to <transition_to>.
      optional(:transition_to).filled(:str?)

      # In order to even take the given action, what other <required_actions>
      # must first have been taken
      optional(:required_actions).each(:str?)

      # The list of states from which this action can be taken.
      #
      # Specify all of the <from_states> in which this action can be taken.
      # The <name> of the state, and the <roles> that people must have in order
      # to take this action.
      optional(:from_states).each do
        schema do
          required(:name).each(:str?)
          required(:roles).each(:str?)
        end
      end

      # Specify any emails that must be sent
      optional(:emails).each { schema(EmailSchema) }

      # Additional attributes that are assigned to the `sipity_processing_strategy_actions`
      # table.
      optional(:attributes).schema do
        # You only have to worryabout this if you care about specifying exactly where this occurs
        optional(:presentation_sequence).filled(:int?, gteq?: 0)

        # This one is odd, because we have to account for taken on behalf of, as well as quorum
        # of people. Most times this will leverage the default of the underlying table
        optional(:allow_repeat_within_current_state).filled(:bool?)
      end
    end
  end
end
