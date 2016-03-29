module Sipity
  module Conversions
    module ToRofHash
      # Responsible for building the access rights in a consistent manner
      class AccessRightsBuilder
        # A convenience method for constructing and calling this function.
        #
        # @api private
        def self.call(**keywords, &block)
          new(**keywords, &block).call
        end

        # @todo We wouldn't need to pass the access_rights_data if we were to create a repository method that can extract that information
        def initialize(work:, access_rights_data:, repository: default_repository)
          self.work = work
          self.access_rights_data = access_rights_data
          self.repository = repository
        end

        def call
          base_access_rights.merge(specific_access_rights)
        end

        private

        attr_accessor :work, :access_rights_data, :repository

        def default_repository
          Sipity::QueryRepository.new
        end

        # @todo Extract this to a more generic location. Figaro perhaps?
        BATCH_USER = 'curate_batch_user'.freeze

        def base_access_rights
          {
            'read' => creator_usernames,
            'edit' => [BATCH_USER],
            'edit-groups' => editing_groups
          }
        end

        def specific_access_rights
          case access_rights_data.access_right_code
          when Models::AccessRight::OPEN_ACCESS
            { 'read-groups' => 'public' }
          when Models::AccessRight::RESTRICTED_ACCESS
            { 'read-groups' => 'restricted' }
          when Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS
            { 'read-groups' => 'public', 'embargo-date' => access_rights_data.transition_date.strftime('%Y-%m-%d') }
          when Models::AccessRight::PRIVATE_ACCESS
            {}
          else
            raise "Unexpected AccessRight for #{access_rights_data.inspect}"
          end
        end

        # @note This only applies to the ETD group; The editing group will need to be parameterized
        def editing_groups
          [Figaro.env.curate_grad_school_editing_group_pid!]
        end

        def creator_usernames
          @creator_usernames ||= Array.wrap(
            repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER)
          ).map(&:username)
        end
      end
    end
  end
end
