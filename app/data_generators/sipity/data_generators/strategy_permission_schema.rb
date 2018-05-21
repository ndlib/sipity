require 'dry/validation/schema'

module Sipity
  module DataGenerators
    StrategyPermissionSchema = Dry::Validation.Schema do
      required(:group).filled(:str?)
      required(:role).filled(:str?)
    end
  end
end
