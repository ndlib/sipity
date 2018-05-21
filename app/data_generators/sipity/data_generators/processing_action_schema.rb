require 'dry/validation/schema'
require 'sipity/data_generators/email_schema'

module Sipity
  module DataGenerators
    ProcessingActionSchema = Dry::Validation.Schema do
      required(:name).filled(:str?)
      optional(:transition_to).filled(:str?)
      # Note: I'm keeping required as, at this point, I'm unable to tweak to use filled
      optional(:required_actions).required { str? | array? { each { str? } } }
      optional(:from_states).each do
        schema do
          # Note: I'm keeping required as, at this point, I'm unable to tweak to use filled
          required(:name).required { str? | array? { each { str? } } }
          # Note: I'm keeping required as, at this point, I'm unable to tweak to use filled
          required(:roles).required { str? | array? { each { str? } } }
        end
      end
      optional(:emails).each { schema(EmailSchema) }
      optional(:attributes).schema do
        optional(:presentation_sequence).filled(:int?, gteq?: 0)
        optional(:allow_repeat_within_current_state).filled(:bool?)
      end
    end
  end
end
