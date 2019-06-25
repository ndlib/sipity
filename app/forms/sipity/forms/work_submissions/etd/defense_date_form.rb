require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Exposes a means defining the thesis defense date todo item.
        class DefenseDateForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work, attribute_names: [:defense_date]
          )

          include Conversions::ExtractInputDateFromInput
          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.defense_date = extract_input_date_from_input(:defense_date, attributes) { defense_date_from_work }
          end

          include ActiveModel::Validations
          validates :defense_date, presence: true

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'defense_date', values: defense_date)
            end
          end

          include Conversions::ConvertToDate
          def defense_date=(value)
            @defense_date = convert_to_date(value) { nil }
          end

          private

          def defense_date_from_work
            repository.work_attribute_values_for(work: work, key: 'defense_date', cardinality: 1)
          end
        end
      end
    end
  end
end
