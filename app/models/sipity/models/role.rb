module Sipity
  module Models
    # A named concept that represents a set of responsibilities/verbs.
    # Often confused for a Group. Group represents people.
    # Roles represent what can/is done by anything/anyone having the given role.
    #
    # @note Should this be in the Processing submodule? Perhaps. This model
    #   representes the "roles" that users of the system can have. It is not
    #   the "role" that they had in relation to the scholarly work that is
    #   being deposited (i.e. co-author on a paper).
    #
    # @see Sipity::Models::Collaborators
    # @see Sipity::Models::Processing::Actor
    class Role < ActiveRecord::Base
      self.table_name = 'sipity_roles'

      has_many(
        :processing_strategy_roles,
        dependent: :destroy,
        class_name: 'Sipity::Models::Processing::StrategyRole'
      )

      has_many(
        :email_recipients,
        dependent: :destroy,
        foreign_key: :role_id,
        class_name: 'Sipity::Models::Notification::EmailRecipient'
      )

      CREATING_USER = 'creating_user'.freeze
      ADVISOR = 'advisor'.freeze
      ETD_REVIEWER = 'etd_reviewer'.freeze
      ULRA_REVIEWER = 'ulra_reviewer'.freeze
      WORK_AREA_MANAGER = 'work_area_manager'.freeze
      WORK_AREA_VIEWER = 'work_area_viewer'.freeze
      WORK_SUBMITTER = 'work_submitter'.freeze
      SUBMISSION_WINDOW_VIEWER = 'submission_window_viewer'.freeze
      CATALOGER = 'cataloger'.freeze

      # As I don't have a means for assigning roles for a given processing type
      # I need a controlled vocabulary for roles.
      enum(
        name: {
          CREATING_USER => CREATING_USER,
          ETD_REVIEWER => ETD_REVIEWER,
          ADVISOR => ADVISOR,
          WORK_AREA_MANAGER => WORK_AREA_MANAGER,
          WORK_AREA_VIEWER => WORK_AREA_VIEWER,
          WORK_SUBMITTER => WORK_SUBMITTER,
          SUBMISSION_WINDOW_VIEWER => SUBMISSION_WINDOW_VIEWER,
          ULRA_REVIEWER => ULRA_REVIEWER,
          CATALOGER => CATALOGER
        }
      )

      def self.[](name)
        find_or_create_by!(name: name.to_s)
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
