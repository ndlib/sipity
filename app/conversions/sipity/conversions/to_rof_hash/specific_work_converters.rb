require 'sipity/exceptions'
require 'sipity/conversions/to_rof_hash/specific_work_converters/etd_converter'
require 'sipity/conversions/to_rof_hash/specific_work_converters/ulra_converters'
module Sipity
  module Conversions
    module ToRofHash
      # Responsible for allowing for different work types to be exported with custom metadata
      module SpecificWorkConverters
        def self.find_and_initialize(work:, base_converter:, repository:)
          converter = instantiate_a_converter(work: work, base_converter: base_converter, repository: repository)
          raise Exceptions::FailedToInitializeWorkConverterError, work: work unless converter
          converter.new(work: work, base_converter: base_converter, repository: repository)
        end

        # NOTE: Hear there be dragons. This is a prime location for plugin architecture to come along and expose a means for new work types
        # to register a conversion to attempt. But at least its isolated.
        def self.instantiate_a_converter(work:, base_converter:, repository:)
          case work.work_type
          when Models::WorkType::DOCTORAL_DISSERTATION, Models::WorkType::MASTER_THESIS
            SpecificWorkConverters::EtdConverter
          when Models::WorkType::ULRA_SUBMISSION
            # NOTE: Locabulary gem for valid values
            case repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::AWARD_CATEGORY, cardinality: 1)
            when 'Senior Thesis'
              SpecificWorkConverters::UlraSeniorThesisConverter
            when '10000 Level', "20000–40000 Level", "Honors Thesis", "Capstone Project"
              SpecificWorkConverters::UlraDocumentConverter
            end
          end
        end
        private_class_method :instantiate_a_converter
      end
    end
  end
end
