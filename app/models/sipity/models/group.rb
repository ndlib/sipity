module Sipity
  module Models
    # Responsible for giving a name to a group of people. This is not the role
    # nor responsibility that those people fill. It is an alias for a collection
    # of people.
    #
    # @see User
    class Group < ActiveRecord::Base
      self.table_name = 'sipity_groups'

      ALL_REGISTERED_USERS = 'All Registered Users'.freeze
      # group used for items sent to batch ingestor
      BATCH_INGESTORS = "Batch Ingestors".freeze
      # ETD integrators is OIT
      ETD_INTEGRATORS = "ETD_INTEGRATORS".freeze

      def self.all_registered_users
        find_or_create_by!(name: ALL_REGISTERED_USERS)
      end

      # Why are there validations here and not on other models? Because I'm
      # not intending to create a form to represent this object. If things get
      # complicated, then a form will happen.
      validates :name, presence: true, uniqueness: true

      has_many :group_memberships, dependent: :destroy
      has_one :processing_actor, as: :proxy_for, class_name: 'Sipity::Models::Processing::Actor'
      has_many :event_logs, class_name: 'Sipity::Models::EventLog', as: :requested_by

      delegate :to_s, to: :name

      def self.basic_authorization_string_for!(name:)
        group = find_by!(name: name)
        return "#{group.name}:#{group.api_key}" if group.api_key?
        raise Exceptions::InvalidAuthorizationCredentialsError, "Expected #{name} to have an API_KEY"
      rescue ActiveRecord::RecordNotFound
        raise Exceptions::InvalidAuthorizationCredentialsError, "Unable to find authorization credentials for #{name}"
      end
    end
  end
end
