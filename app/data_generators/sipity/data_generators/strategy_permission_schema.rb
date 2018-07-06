require 'dry/validation/schema'

module Sipity
  module DataGenerators
    StrategyPermissionSchema = Dry::Validation.Schema do
      # What named <group> gets the named <role>. In other words,
      # everyone that has the given <group> will get the given <role>.
      # In this context, it is envisioned the <group> getting the
      # <role> for all entities in the given workflow.
      required(:group).filled(:str?)
      required(:role).filled(:str?)
    end
  end
end
