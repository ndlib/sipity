module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for degree.
      class DegreeForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @degree = attributes.fetch(:degree) { degree_from_work }
          @program_name = attributes.fetch(:program_name) { program_name_from_work }
        end

        attr_accessor :degree
        attr_accessor :program_name

        validates :degree, presence: true
        validates :program_name, presence: true

        def degree_names
          repository.get_values_by_predicate_name(name: 'degree')
        end

        def programs
          repository.get_values_by_predicate_name(name: 'program')
        end

        private

        def save(requested_by:)
          super do
            repository.update_work_attribute_values!(work: work, key: 'degree', values: degree)
            repository.update_work_attribute_values!(work: work, key: 'program_name', values: program_name)
          end
        end

        def degree_from_work
          repository.work_attribute_values_for(work: work, key: 'degree')
        end

        def program_name_from_work
          repository.work_attribute_values_for(work: work, key: 'program_name')
        end
      end
    end
  end
end
