require_relative '../../../forms'
module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Responsible for calling the ETD Ingester
        class SubmitForFileReingestForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: []
          )

          def initialize(work:, requested_by:, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
          end

          include ActiveModel::Validations
          validate :check_if_authorized

          def submit
            processing_action_form.submit do
              exporter.call(work: work)
            end
          end

          private

          def check_if_authorized
            return true if repository.authorized_for_processing?(user: requested_by, entity: work, action: processing_action_name)
            errors.add(:base, :unauthorized)
          end

          def exporter
            Exporters::FileReplacementExporter
          end
        end
      end
    end
  end
end
