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
      BATCH_INGESTORS = "Batch Ingestors".freeze

      def self.batch_ingestors
        find_by!(name: BATCH_INGESTORS)
      end

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
    end
  end
end
