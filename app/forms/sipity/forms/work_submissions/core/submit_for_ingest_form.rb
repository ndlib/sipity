require_relative '../../../forms'
module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Responsible for calling the ETD Ingester
        class SubmitForIngestForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:exporter]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.exporter = attributes.fetch(:exporter)
          end

          include ActiveModel::Validations
          validate :check_if_authorized

          def submit
            processing_action_form.submit do
              exporter.call(work)
            end
          end

          private

          def check_if_authorized
            return true if repository.authorized_for_processing?(user: requested_by, entity: work, action: processing_action_name)
            errors.add(:base, :unauthorized)
          end

          def exporter=(input)
            @exporter = PowerConverter.convert(input, to: :exporter_function)
          end
        end
      end
    end
  end
end
