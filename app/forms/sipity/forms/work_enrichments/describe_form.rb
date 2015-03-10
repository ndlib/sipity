module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for describe.
      class DescribeForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          self.title = attributes.fetch(:title) { title_from_work }
          self.abstract = attributes.fetch(:abstract) { abstract_from_work }
          self.discipline = attributes.fetch(:discipline) { discipline_from_work }
          self.alternate_title = attributes.fetch(:alternate_title) { alternate_title_from_work }
        end

        attr_accessor :discipline, :alternate_title, :abstract, :title
        private :discipline=, :alternate_title=, :abstract=, :title=

        validates :title, presence: true
        validates :abstract, presence: true
        validates :discipline, presence: true

        private

        def save(requested_by:)
          super do
            repository.update_work_title!(work: work, title: title)
            repository.update_work_attribute_values!(work: work, key: 'abstract', values: abstract)
            repository.update_work_attribute_values!(work: work, key: 'discipline', values: discipline)
            repository.update_work_attribute_values!(work: work, key: 'alternate_title', values: alternate_title)
          end
        end

        def abstract_from_work
          repository.work_attribute_values_for(work: work, key: 'abstract').first
        end

        def discipline_from_work
          repository.work_attribute_values_for(work: work, key: 'discipline').first
        end

        def alternate_title_from_work
          repository.work_attribute_values_for(work: work, key: 'alternate_title').first
        end

        def title_from_work
          return '' unless work
          work.title
        end
      end
    end
  end
end
