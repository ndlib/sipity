require_relative '../../../forms'
module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for calling the ETD Ingester
        class SubmitForIngestForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: []
          )

          def initialize(work:, requested_by:, exporter: default_exporter, _attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.exporter = exporter
          end

          include ActiveModel::Validations
          validate :check_if_authorized
          attr_accessor :exporter

          def submit
            processing_action_form.submit do
              exporter.call(work)
            end
          end

          private

          def check_if_authorized
            return true if repository.authorized_for_processing?(user: requested_by, entity: work, action: 'submit_for_ingest')
            errors.add(:base, :unauthorized)
          end

          def default_exporter
            require 'sipity/exporters/etd_exporter'
            Exporters::EtdExporter
          end
        end
      end
    end
  end
end
