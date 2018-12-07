require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing and validating information for administrative unit.
        class AdministrativeUnitForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:administrative_unit]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.administrative_unit = attributes.fetch(:administrative_unit) { administrative_unit_from_work }
          end

          include ActiveModel::Validations
          validates :administrative_unit, presence: true
          validates :work, presence: true

          def available_administrative_units
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'administrative_units')
          end

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'administrative_unit', values: administrative_unit)
            end
          end

          private

          def administrative_unit_from_work
            repository.work_attribute_values_for(work: work, key: 'administrative_unit', cardinality: :many)
          end
        end
      end
    end
  end
end
