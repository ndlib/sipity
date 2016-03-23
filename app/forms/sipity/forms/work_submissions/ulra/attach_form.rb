require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Exposes a means for attaching files to the associated work.
        class AttachForm
          ProcessingForm.configure(
            attribute_names: [
              :project_url, :files, :attachments_attributes, :representative_attachment_id, :attached_files_completion_state
            ],
            base_class: Models::Work,
            form_class: self,
            processing_subject_name: :work
          )

          class_attribute :attachment_predicate_name, instance_predicate: false, instance_writer: false
          self.attachment_predicate_name = 'project_file'.freeze

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.representative_attachment_id = attributes.fetch(:representative_attachment_id) { representative_attachment_id_from_work }
            self.project_url = attributes.fetch(:project_url) { project_url_from_work }
            self.attached_files_completion_state = attributes.fetch(:attached_files_completion_state) do
              attached_files_completion_state_from_work
            end
            self.attachments_extension = build_attachments(attributes.slice(:files, :attachments_attributes))
          end

          private

          attr_accessor :attachments_extension

          public

          include ActiveModel::Validations
          validate :at_least_one_file_must_be_attached
          validates :work, presence: true
          validates :requested_by, presence: true
          validates(
            :attached_files_completion_state,
            presence: true,
            inclusion: { in: ->(record) { record.possible_attached_files_completion_states } }
          )

          INCOMPLETE_STATE =
            'a representative sample of my project (only applicable for senior/honors thesis or capstone project submissions)'.freeze
          COMPLETE_STATE = 'the final version of my project'.freeze

          def possible_attached_files_completion_states
            [INCOMPLETE_STATE, COMPLETE_STATE]
          end

          delegate(
            :attachments, :attachments_metadata, :attach_or_update_files, :attachments_attributes=, :files,
            :at_least_one_file_must_be_attached, to: :attachments_extension
          )
          private(:attach_or_update_files)

          def submit
            processing_action_form.submit { save }
          end

          private

          def save
            repository.set_as_representative_attachment(work: work, pid: representative_attachment_id)
            attach_or_update_files(requested_by: requested_by)
            update_additional_attributes(keys: ['attached_files_completion_state', 'project_url'])
          end

          def update_additional_attributes(keys:)
            keys.each { |key| repository.update_work_attribute_values!(work: work, key: key, values: send(key)) }
          end

          def representative_attachment_id_from_work
            repository.representative_attachment_for(work: work).to_param
          end

          def attached_files_completion_state_from_work
            repository.work_attribute_values_for(work: work, key: 'attached_files_completion_state', cardinality: 1)
          end

          def project_url_from_work
            repository.work_attribute_values_for(work: work, key: 'project_url', cardinality: 1)
          end

          def build_attachments(attachment_attr)
            ComposableElements::AttachmentsExtension.new(
              form: self,
              repository: repository,
              files: attachment_attr[:files],
              predicate_name: attachment_predicate_name,
              attachments_attributes: attachment_attr[:attachments_attributes]
            )
          end
        end
      end
    end
  end
end
