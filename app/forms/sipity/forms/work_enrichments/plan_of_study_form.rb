module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for plan_of_study.
      class PlanOfStudyForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          self.expected_graduation_date = attributes.fetch(:expected_graduation_date) { expected_graduation_date_from_work }
          self.majors = attributes.fetch(:majors) { majors_from_work }
        end

        attr_reader :expected_graduation_date, :majors

        validates :expected_graduation_date, presence: true
        validates :majors, presence: true

        private

        def save(requested_by:)
          super do
            repository.update_work_attribute_values!(work: work, key: 'expected_graduation_date', values: expected_graduation_date)
            repository.update_work_attribute_values!(work: work, key: 'majors', values: majors)
          end
        end

        def expected_graduation_date_from_work
          repository.work_attribute_values_for(work: work, key: 'expected_graduation_date')
        end

        def majors_from_work
          repository.work_attribute_values_for(work: work, key: 'majors')
        end

        def majors=(values)
          @majors = to_array_without_empty_values(values)
        end

        include Conversions::ConvertToDate
        def expected_graduation_date=(value)
          @expected_graduation_date = convert_to_date(value) { nil }
        end

        def to_array_without_empty_values(value)
          Array.wrap(value).select(&:present?)
        end
      end
    end
  end
end
