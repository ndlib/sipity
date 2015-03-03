module Sipity
  # :nodoc:
  module Commands
    # Commands
    module WorkCommands
      # Responsible for assigning collaborators to a work.
      def assign_collaborators_to(work:, collaborators:)
        # TODO: Encapsulate this is a Service Object as there is enough logic
        # to warrant this behavior.
        Array.wrap(collaborators).each do |collaborator|
          collaborator.work_id = work.id
          collaborator.save!
          next unless collaborator.responsible_for_review?
          create_sipity_user_from(netid: collaborator.netid) do |user|
            PermissionCommands.grant_permission_for!(actors: user, entity: work, acting_as: Models::Role::ADVISOR)
          end
        end
      end

      def create_work!(attributes = {})
        # TODO: Encapsulate this into a Service Object as there is logic spilling
        #   around.
        Models::Work.create!(attributes.slice(:title, :work_publication_strategy, :work_type)) do |work|
          named_work_type = attributes.fetch(:work_type)
          work_type = Models::WorkType.find_or_create_by!(name: named_work_type)
          # A bit of a weirdness as I splice in the new behavior
          strategy = attributes.fetch(:processing_strategy) { work_type.find_or_initialize_default_processing_strategy.tap(&:save!) }
          strategy_state = attributes.fetch(:processing_strategy_state) { strategy.initial_strategy_state }
          work.build_processing_entity(strategy_state: strategy_state, strategy: strategy)
        end
      end

      # This may look ridiculous, but I'd like to isolate the destruction so
      # that I can associate any other actions with it (i.e. logging, emails, etc.)
      def destroy_a_work(work:)
        work.destroy
      end

      def update_processing_state!(entity:, to:)
        Services::UpdateEntityProcessingState.call(entity: entity, processing_state: to)
      end

      def attach_files_to(work:, files:, user:, pid_minter: default_pid_minter)
        # I know I want the user, but I'm not certain what we are doing with it
        # just yet.
        _user = user
        Array.wrap(files).each do |file|
          pid = pid_minter.call
          Models::Attachment.create!(work: work, file: file, pid: pid, predicate_name: 'attachment')
        end
      end

      def remove_files_from(work:, user:, pids:)
        _user = user # Don't need it yet, but it makes sense to capture this
        Models::Attachment.where(work: work, pid: Array.wrap(pids)).destroy_all
      end

      def amend_files_metadata(work:, user:, metadata: {})
        _work, _user, _files = work, user, metadata
        metadata.each do |pid, data|
          Models::Attachment.where(work: work).find(pid).
            update_attributes!(data.with_indifferent_access.slice(:name))
        end
      end

      def mark_as_representative(work:, pid:, user: user)
        attachment = Models::Attachment.find_by(pid: pid)
        return true unless attachment.present?
        Models::Attachment.where(work_id: work.id, is_representative_file: true).update_all(is_representative_file: false)
        attachment.update(is_representative_file: true)
      end

      def create_sipity_user_from(netid:)
        return false unless netid.present?
        # This assumes a valid NetID.
        user = User.find_or_create_by!(username: netid)
        yield(user) if block_given?
        user
      end

      # @return [#call] A call-able object that when called will return a String
      #
      # @note This is not a PID as per Fedora 3, but is something random,
      #   unique, and stringy. Which for these purposes is adequate.
      def default_pid_minter
        -> { SecureRandom.urlsafe_base64(nil, true) }
      end

      def apply_access_policies_to(work:, user:, access_policies:)
        Services::ApplyAccessPoliciesTo.call(work: work, user: user, access_policies: access_policies)
      end
    end
  end
end
