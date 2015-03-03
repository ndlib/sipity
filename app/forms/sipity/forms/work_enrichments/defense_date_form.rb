module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means defining the thesis defense date todo item.
      class DefenseDateForm < Forms::WorkEnrichmentForm
        include Conversions::ExtractInputDateFromInput
        def initialize(attributes = {})
          super
          self.defense_date = extract_input_date_from_input(:defense_date, attributes) { defense_date_from_work }
        end

        attr_reader :defense_date
        validates :defense_date, presence: true

        private

        def save(requested_by:)
          super do
            repository.update_work_attribute_values!(work: work, key: 'defense_date', values: defense_date)
          end
        end

        def defense_date_from_work
          return nil unless work
          Array.wrap(repository.work_attribute_values_for(work: work, key: 'defense_date')).first
        end

        include Conversions::ConvertToDate
        def defense_date=(value)
          @defense_date = convert_to_date(value) { nil }
        end
      end
    end
  end
end
