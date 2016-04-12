module Sipity
  module Conversions
    module ToRof
      # Responsible for building the access rights in a consistent manner
      class AccessRightsBuilder
        # A convenience method for constructing and calling this function.
        #
        # @api private
        def self.to_hash(**keywords, &block)
          new(**keywords, &block).to_hash
        end

        # @todo We wouldn't need to pass the access_rights_data if we were to create a repository method that can extract that information
        def initialize(work:, access_rights_data:, edit_groups: [], repository: default_repository)
          self.work = work
          self.access_rights_data = access_rights_data
          self.repository = repository
          self.edit_groups = edit_groups
        end

        def to_hash
          base_access_rights.merge(specific_access_rights)
        end

        private

        attr_accessor :work, :access_rights_data, :repository

        def default_repository
          Sipity::QueryRepository.new
        end

        attr_reader :edit_groups
        def edit_groups=(input)
          @edit_groups = Array.wrap(input)
        end

        # @todo Extract this to a more generic location. Figaro perhaps?
        BATCH_USER = 'curate_batch_user'.freeze

        def base_access_rights
          {
            'read' => creator_usernames,
            'edit' => [BATCH_USER],
            'edit-groups' => edit_groups
          }
        end

        def specific_access_rights
          case access_rights_data.access_right_code
          when Models::AccessRight::OPEN_ACCESS
            { 'read-groups' => ['public'] }
          when Models::AccessRight::RESTRICTED_ACCESS
            { 'read-groups' => ['restricted'] }
          when Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS
            { 'read-groups' => ['public'], 'embargo-date' => access_rights_data.transition_date.strftime('%Y-%m-%d') }
          when Models::AccessRight::PRIVATE_ACCESS
            {}
          else
            raise "Unexpected AccessRight for #{access_rights_data.inspect}"
          end
        end

        # @note This is a rather critical assumption
        def creator_usernames
          @creator_usernames ||= Array.wrap(
            repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER)
          ).map(&:username)
        end
      end
    end
  end
end
