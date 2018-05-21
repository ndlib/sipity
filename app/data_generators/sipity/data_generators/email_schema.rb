require 'dry/validation/schema'

module Sipity
  module DataGenerators
    EmailSchema = Dry::Validation.Schema do
      required(:name).filled(:str?)
      # Note: I'm keeping required as, at this point, I'm unable to tweak to use filled
      required(:to).required  { str? | array? { each { str? } } }
      # Note: I'm keeping required as, at this point, I'm unable to tweak to use filled
      optional(:cc).required  { str? | array? { each { str? } } }
      # Note: I'm keeping required as, at this point, I'm unable to tweak to use filled
      optional(:bcc).required  { str? | array? { each { str? } } }
    end
  end
end
