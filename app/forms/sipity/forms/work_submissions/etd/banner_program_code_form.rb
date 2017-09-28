require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing the banner program code
        class BannerProgramCodeForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:banner_program_code]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.banner_program_code = attributes.fetch(:banner_program_code) { banner_program_code_from_work }
          end

          include ActiveModel::Validations
          validates :banner_program_code, presence: true
          validates :work, presence: true

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'banner_program_code', values: banner_program_code)
            end
          end

          private

          def banner_program_code_from_work
            repository.work_attribute_values_for(work: work, key: 'banner_program_code', cardinality: 1)
          end
        end
      end
    end
  end
end
