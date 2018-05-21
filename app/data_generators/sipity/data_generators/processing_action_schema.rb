require 'dry/validation/schema'
require 'sipity/data_generators/email_schema'

module Sipity
  module DataGenerators
    ProcessingActionSchema = Dry::Validation.Schema do
      required(:name).filled(:str?)
      optional(:transition_to).filled(:str?)
      optional(:required_actions).each(:str?)
      optional(:from_states).each do
        schema do
          required(:name).each(:str?)
          required(:roles).each(:str?)
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
