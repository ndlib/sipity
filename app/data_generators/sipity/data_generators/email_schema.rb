module Sipity
  module DataGenerators
    EmailSchema = Dry::Schema.JSON do
      required(:name).filled(:str?)
      required(:to).value(:array).each(:str?)
      optional(:cc).value(:array).each(:str?)
      optional(:bcc).value(:array).each(:str?)
    end
  end
end
