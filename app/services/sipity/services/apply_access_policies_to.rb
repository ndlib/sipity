module Sipity
  module Services
    # Responsible for rebuilding access policies for accessible objects
    # associated with the given work.
    class ApplyAccessPoliciesTo
      def initialize(user:, work:, access_policies:)
        @user = user
        @work = work
        @access_policies = Array.wrap(access_policies)
      end
      attr_reader :user, :work, :access_policies, :repository

      def call
        access_policies.each do |attributes|
          expunge_previous_access_rights(attributes)
          access_right_code = attributes.fetch(:access_right_code)
          case access_right_code
          when Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS
            handle_embargo_based_access_right(attributes)
          else
            handle_non_embargo_based_access_right(attributes)
          end
        end
      end

      private

      def handle_embargo_based_access_right(attributes)
        Models::AccessRight.create!(attributes.slice(:entity_id, :entity_type)) do |embargoed|
          embargoed.access_right_code = Models::AccessRight::PRIVATE_ACCESS
          embargoed.enforcement_start_date = Date.today
          embargoed.enforcement_end_date = attributes.fetch(:release_date)
        end
        Models::AccessRight.create!(attributes.slice(:entity_id, :entity_type)) do |open_access|
          open_access.access_right_code = Models::AccessRight::OPEN_ACCESS
          open_access.enforcement_start_date = attributes.fetch(:release_date)
          open_access.enforcement_end_date = nil
        end
      end

      def handle_non_embargo_based_access_right(attributes)
        Models::AccessRight.create!(attributes.slice(:entity_id, :access_right_code, :entity_type)) do |access_right|
          access_right.enforcement_start_date = Date.today
          access_right.enforcement_end_date = nil
        end
      end

      def expunge_previous_access_rights(attributes)
        Models::AccessRight.where(attributes.slice(:entity_id, :entity_type)).destroy_all
      end
    end
  end
end
