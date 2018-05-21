require 'dry/validation/schema'

module Sipity
  module DataGenerators
    EmailSchema = Dry::Validation.Schema do
      required(:name).filled(:str?)
      required(:to).each(:str?)
      optional(:cc).each(:str?)
      optional(:bcc).each(:str?)
    end
  end
end
