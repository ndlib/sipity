require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Exposes a means for attaching a new version of a file on a work.
        class UpdateFileForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:attachments]
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

          include ActiveModel::Validations
          validates :work, presence: true
          validates :requested_by, presence: true
          validate :only_one_file_may_be_uploaded
          validate :only_one_file_may_be_selected

          delegate(
            :attachments,
            :only_one_file_may_be_selected,
            :only_one_file_may_be_uploaded,
            :attach_new_version,
            :attachments_attributes=,
            :files,
            to: :attachments_extension
          )
          private(:attach_new_version)

          def submit
            processing_action_form.submit { update }
          end

          private

          def update
            attach_new_version(requested_by: requested_by)
          end

          def build_attachments(attachment_attr)
            ComposableElements::AttachmentsExtension.new(
              form: self,
              repository: repository,
              files: attachment_attr[:files],
              attachments_attributes: attachment_attr[:attachments_attributes]
            )
          end
        end
      end
    end
  end
end
