module Sipity
  module Decorators
    # A decoration layer for Sipity::Models::Work
    class EmailNotificationDecorator < ApplicationDecorator
      # TODO
      # Add implementations to the methods
      def self.object_class
        Models::Work
      end

      alias_method :entity, :object

      delegate_all

      def document_type
        entity.work_type.humanize
      end

      def director
      end

      def approval_date
      end

      def approved_by_directors
      end

      def permission_for_third_party_materials
      end

      def comments
        []
      end

      def work_show_path
        view_context.work_path(entity.id)
      end

      alias_method :review_link, :work_show_path

      def curate_link
      end

      def creators
        @creators ||= repository.scope_users_for_entity_and_roles(entity: entity, roles: Models::Role::CREATING_USER)
      end

      def creator_names
        creators.map(&:name).to_sentence
      end

      def creator_usernames
        creators.map(&:username).to_sentence
      end

      def netid
      end

      def degree
      end

      def graduate_programs
      end

      def release_date
      end

      def access_rights
        Array.wrap(repository.work_access_right_codes(work: entity)).map(&:titleize).to_sentence
      end

      def will_be_released_to_the_public?
      end

      private

      def view_context
        Draper::ViewContext.current
      end
    end
  end
end
