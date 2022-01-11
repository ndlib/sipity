module Sipity
  module Forms
    module ComposableElements
      # Responsible for file attachments
      class AttachmentsExtension
        def initialize(form:, repository:, **args)
          self.form = form
          self.repository = repository
          self.files = args[:files] || {}
          self.predicate_name = args.fetch(:predicate_name) { default_predicate_name }
          self.attachments_attributes = args[:attachments_attributes] || {}
        end

        attr_accessor :form, :repository, :predicate_name
        attr_reader :attachments_attributes, :files
        private(:form=, :repository=, :predicate_name=)

        alias attachment_predicate_name predicate_name

        delegate :action, :work, :errors, to: :form

        def attachments
          @attachments ||= attachments_from_work
        end

        def attachments_attributes=(value)
          @attachments_attributes = value
          collect_files_for_deletion_and_update
        end

        def attach_or_update_files(requested_by:)
          update_attachments(requested_by: requested_by)
          update_attachment_metadata(requested_by: requested_by)
          unregister_access_policy_action_for(requested_by: requested_by)
        end

        def attach_new_version(requested_by:)
          repository.replace_file_version(work: work, file: files.first, pid: id_for_replacement, predicate_name: 'attachment')
        end

        def update_attachments(requested_by:)
          repository.attach_files_to(work: work, files: files, predicate_name: predicate_name) if files.any?
          repository.remove_files_from(work: work, user: requested_by, pids: ids_for_deletion, predicate_name: predicate_name)
        end

        def update_attachment_metadata(requested_by:)
          repository.amend_files_metadata(work: work, user: requested_by, metadata: attachments_metadata)
        end

        def unregister_access_policy_action_for(requested_by:)
          # NOTE: This only unregisters the action if it has been taken by the given person.
          repository.unregister_action_taken_on_entity(entity: work, action: 'access_policy', requested_by: requested_by)
        end

        # Exposed so that it can be used
        # for validations outside of this class
        def attachments_metadata
          @attachments_metadata || {}
        end

        def attachments_associated_with_the_work?
          attachments_metadata.present? || Array.wrap(files).any?(&:present?)
        end

        def exactly_one_selection?
          selected_for_replace = []
          attachments_attributes.each do |_keys, attributes|
            selected_for_replace << PowerConverter.convert(attributes['replace'], to: :boolean)
          end
          return true if selected_for_replace.count(true) == 1
          false
        end

        def new_file_uploaded?
          Array.wrap(files).any?(&:present?)
        end

        def at_least_one_file_must_be_attached
          return true if attachments_associated_with_the_work?
          errors.add(:base, :at_least_one_attachment_required)
        end

        def only_one_file_may_be_selected
          return true if exactly_one_selection?
          errors.add(:base, :exactly_one_selection_required)
        end

        def only_one_file_may_be_uploaded
          return true if new_file_uploaded?
          errors.add(:base, :must_upload_new_file_version)
        end

        private

        def default_predicate_name
          'attachment'
        end

        def files=(input)
          @files = Array.wrap(input)
        end

        def ids_for_deletion
          collect_files_for_deletion_and_update
          @ids_for_deletion || []
        end

        def collect_files_for_deletion_and_update
          @ids_for_deletion = []
          @attachments_metadata = {}
          attachments_attributes.each do |_key, attributes|
            if PowerConverter.convert(attributes['delete'], to: :boolean)
              @ids_for_deletion << attributes.fetch('id')
            else
              @attachments_metadata[attributes.fetch('id')] = extract_permitted_attributes(attributes, 'name')
            end
          end
        end

        def id_for_replacement
          @id_for_replacement = ""
          # we have already validated there is only one but we use each to extract the info
          attachments_attributes.each do |_key, attributes|
            if PowerConverter.convert(attributes['replace'], to: :boolean)
              @id_for_replacement = attributes.fetch('id')
            end
          end
          @id_for_replacement
        end

        # Because strong parameters might be in play, I need to make sure to
        # permit these, or things fall apart later in the application.
        def extract_permitted_attributes(attributes, *keys)
          permitted_attributes = attributes.slice(*keys)
          permitted_attributes.permit! if permitted_attributes.respond_to?(:permit!)
          permitted_attributes
        end

        def attachments_from_work
          repository.work_attachments(work: work, predicate_name: attachment_predicate_name).map do |attachment|
            AttachmentFormElement.new(attachment)
          end
        end

        # Responsible for exposing a means of displaying and marking the object for processing.
        class AttachmentFormElement
          def initialize(attachment)
            self.attachment = attachment
          end
          delegate :id, :name, :thumbnail_url, :persisted?, :file_url, to: :attachment
          attr_accessor :delete, :replace

          private

          attr_accessor :attachment
        end
        private_constant :AttachmentFormElement
      end
    end
  end
end
