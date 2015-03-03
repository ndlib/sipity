module Sipity
  module Services
    # Responsible for rebuilding access policies for accessible objects
    # associated with the given work.
    class ApplyAccessPoliciesTo
      def self.call(options = {})
        new(options.slice(:user, :work, :access_policies)).call
      end

      def initialize(user:, work:, access_policies:)
        @user = user
        @work = work
        @access_policies = Array.wrap(access_policies)
      end
      attr_reader :user, :work, :access_policies, :repository

      def call
        access_policies.each do |attributes|
          find_or_create_access_right_from(attributes)
        end
      end

      private

      include Conversions::ConvertToDate

      def find_or_create_access_right_from(attributes)
        Models::AccessRight.find_or_initialize_by(attributes.slice(:entity_id, :entity_type)) do |access_right|
          access_right.access_right_code = attributes.fetch(:access_right_code)
          access_right.release_date = convert_to_date(attributes.fetch(:release_date)) { nil }
        end.save!
      end
    end
  end
end
