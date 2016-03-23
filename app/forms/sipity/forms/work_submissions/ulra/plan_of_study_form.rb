require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for capturing and validating information for plan_of_study.
        class PlanOfStudyForm
          ProcessingForm.configure(
            attribute_names: [:expected_graduation_term, :majors, :minors, :primary_college, :underclass_level],
            base_class: Models::Work,
            form_class: self,
            processing_subject_name: :work
          )

          include Conversions::ExtractInputDateFromInput
          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.expected_graduation_term = extract_input_date_from_input(:expected_graduation_term, attributes) do
              expected_graduation_term_from_work
            end
            self.majors = attributes.fetch(:majors) { majors_from_work }
            self.minors = attributes.fetch(:minors) { minors_from_work }
            self.primary_college = attributes.fetch(:primary_college) { primary_college_from_work }
            self.underclass_level = attributes.fetch(:underclass_level) { underclass_level_from_work }
          end

          include ActiveModel::Validations
          include Hydra::Validations
          validates :expected_graduation_term, presence: true, inclusion: { in: :possible_expected_graduation_terms }
          validates :underclass_level, presence: true, inclusion: { in: :possible_underclass_levels }
          validates :majors, presence: true
          validates :primary_college, presence: true, inclusion: { in: :possible_primary_colleges }

          def possible_expected_graduation_terms
            repository.possible_expected_graduation_terms
          end

          def submit
            processing_action_form.submit do
              ['expected_graduation_term', 'majors', 'minors', "primary_college", 'underclass_level'].each do |predicate_name|
                repository.update_work_attribute_values!(work: work, key: predicate_name, values: send(predicate_name))
              end
            end
          end

          def possible_primary_colleges
            repository.get_controlled_vocabulary_values_for_predicate_name(name: "college")
          end

          def possible_underclass_levels
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'underclass_level')
          end

          private

          def expected_graduation_term_from_work
            repository.work_attribute_values_for(work: work, key: 'expected_graduation_term', cardinality: 1)
          end

          def primary_college_from_work
            repository.work_attribute_values_for(work: work, key: "primary_college", cardinality: 1)
          end

          def majors_from_work
            repository.work_attribute_values_for(work: work, key: 'majors', cardinality: :many)
          end

          def minors_from_work
            repository.work_attribute_values_for(work: work, key: 'minors', cardinality: :many)
          end

          def underclass_level_from_work
            repository.work_attribute_values_for(work: work, key: 'underclass_level', cardinality: 1)
          end

          def majors=(input)
            @majors = to_array_without_empty_values(input)
          end

          def minors=(input)
            @minors = to_array_without_empty_values(input)
          end

          def to_array_without_empty_values(value)
            Array.wrap(value).select(&:present?)
          end
        end
      end
    end
  end
end
