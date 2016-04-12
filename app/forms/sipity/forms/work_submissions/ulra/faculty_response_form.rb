require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for capturing and validating information for faculty comments
        class FacultyResponseForm
          ProcessingForm.configure(
            attribute_names: [],
            base_class: Models::Work,
            form_class: self,
            processing_subject_name: :work
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.attachments_extension = build_attachments(attributes.slice(:files, :attachments_attributes))
          end

          private

          attr_accessor :attachments_extension

          public

          delegate(
            :attachments, :attach_or_update_files, :attachments_attributes=, :files, :attachment_predicate_name,
            :at_least_one_file_must_be_attached, to: :attachments_extension
          )
          private(:attach_or_update_files)

          include ActiveModel::Validations
          validate :at_least_one_file_must_be_attached

          def submit
            processing_action_form.submit do
              attach_or_update_files(requested_by: requested_by)
            end
          end

          private

          def build_attachments(attachment_attr)
            ComposableElements::AttachmentsExtension.new(
              form: self,
              repository: repository,
              files: attachment_attr[:files],
              predicate_name: 'faculty_letter_of_recommendation',
              attachments_attributes: attachment_attr[:attachments_attributes]
            )
          end
        end
      end
    end
  end
end
