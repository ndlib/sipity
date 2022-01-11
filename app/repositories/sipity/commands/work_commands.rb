require 'active_support/core_ext/array/wrap'

module Sipity
  # :nodoc:
  module Commands
    # Commands
    module WorkCommands
      # Responsible for adding collaborators to the work and removing anyone
      # else.
      def manage_collaborators_for(work:, collaborators:)
        Services::ManageCollaborators.manage_collaborators_for(work: work, collaborators: collaborators, repository: self)
      end

      def assign_collaborators_to(work:, collaborators:)
        Services::ManageCollaborators.assign_collaborators_to(work: work, collaborators: collaborators, repository: self)
      end

      def create_work!(submission_window:, **attributes)
        Services::CreateWorkService.call(submission_window: submission_window, repository: self, **attributes)
      end

      def update_work_title!(work:, title:)
        work.update!(title: title)
      end

      # This may look ridiculous, but I'd like to isolate the destruction so
      # that I can associate any other actions with it (i.e. logging, emails, etc.)
      def destroy_a_work(work:)
        work.destroy
      end

      def update_processing_state!(entity:, to:)
        Services::UpdateEntityProcessingState.call(entity: entity, processing_state: to, repository: self)
      end

      def attach_files_to(work:, files:, predicate_name: 'attachment', **keywords)
        # I know I want the user, but I'm not certain what we are doing with it
        # just yet.
        pid_minter = keywords.fetch(:pid_minter) { default_pid_minter }
        Array.wrap(files).each do |file|
          next unless file.present? # because we may have gotten [{}]
          pid = pid_minter.call
          Models::Attachment.create!(work: work, file: file, pid: pid, predicate_name: predicate_name)
        end
      end

      def replace_file_version(work:, file:, pid:, predicate_name: 'attachment', **keywords)
        Models::Attachment.where(work: work).find(pid).update_version_with!(new_file: file)
      end

      def remove_files_from(work:, user:, pids:, predicate_name: 'attachment')
        _user = user # Don't need it yet, but it makes sense to capture this
        Models::Attachment.where(work: work, pid: Array.wrap(pids), predicate_name: predicate_name).destroy_all
      end

      def amend_files_metadata(work:, user:, metadata: {})
        _user = user
        metadata.each do |pid, data|
          Models::Attachment.where(work: work).find(pid).
            update_attributes!(data.with_indifferent_access.slice(:name))
        end
      end

      def set_as_representative_attachment(work:, pid:)
        attachment = Models::Attachment.find_by(work_id: work.id, pid: pid)
        return true unless attachment.present?
        Models::Attachment.where(work_id: work.id, is_representative_file: true).where.not(pid: attachment.pid).
          update_all(is_representative_file: false)
        Models::Attachment.where(work_id: work.id, pid: attachment.pid).update_all(is_representative_file: true)
      end

      # @return [#call] A call-able object that when called will return a String
      #
      # @note This is not a PID as per Fedora 3, but is something random,
      #   unique, and stringy. Which for these purposes is adequate.
      def default_pid_minter
        Rails.application.config.default_pid_minter
      end

      def apply_access_policies_to(work:, user:, access_policies:)
        Services::ApplyAccessPoliciesTo.call(work: work, user: user, access_policies: access_policies)
      end
    end
  end
end
