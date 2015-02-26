module Sipity
  module Decorators
    # A decoration layer for Sipity::Models::Work
    class EmailNotificationDecorator < ApplicationDecorator
      # TODO
      # Add implementations to the methods

      def self.object_class
        Sipity::Models::Work
      end
      delegate_all

      def document_type
        work_type.humanize
      end

      def director
      end

      def approval_date
      end

      def approved_by_directors
      end

      def review_link_for_grad_school
      end

      def review_link_for_advisor
      end

      def permission_for_third_party_materials
      end

      def comments
        []
      end

      def url
      end

      def curate_link
      end

      def creator
      end

      def netid
      end

      def degree
      end

      def graduate_programs
      end

      def release_date
      end

      def access_right
        access_right_code.sub('_', " ").split.map(&:capitalize).join(' ') if access_right_code
      end

      def access_right_code
        access_rights.first.access_right_code if access_rights.any?
      end

      def will_be_released_to_the_public?
      end
    end
  end
end
