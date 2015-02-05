module Sipity
  module Models
    # A named concept that represents a set of responsibilities/verbs.
    # Often confused for a Group. Group represents people.
    # Roles represent what can/is done by anything/anyone having the given role.
    class Role < ActiveRecord::Base
      self.table_name = 'sipity_roles'

      has_many :processing_strategy_roles,
        dependent: :destroy,
        class_name: 'Sipity::Models::Processing::StrategyRole'

      # As I don't have a means for assigning roles for a given processing type
      # I need a controlled vocabulary for roles.
      enum(
        name: {
          'creating_user' => 'creating_user',
          'etd_reviewer' => 'etd_reviewer',
          'advisor' => 'advisor'
        }
      )

      def self.[](name)
        where(name: name.to_s).first!
      end

      def self.valid_names
        names.keys
      end

      def to_s
        name
      end
    end
  end
end
