require 'sipity/exceptions'
require 'sipity/conversions/to_rof_hash/work_converters/etd_converter'
require 'sipity/conversions/to_rof_hash/work_converters/ulra_converters'

module Sipity
  module Conversions
    module ToRofHash
      # Responsible for converting a work to an ROF hash. This is a bit more
      # complicated as the work's work_type defines the data structure.
      module WorkConverter
        # @api public
        #
        # @param work [Sipity::Models::Work]
        # @return [Hash]
        # @raise Exceptions::FailedToInitializeWorkConverterError when we don't know how to convert this object
        def self.call(work:, **keywords)
          find_and_initialize(work: work, **keywords).to_hash
        end

        def self.find_and_initialize(work:, repository: default_repository)
          converter = instantiate_a_converter(work: work, repository: repository)
          raise Exceptions::FailedToInitializeWorkConverterError, work: work unless converter
          converter.new(work: work, repository: repository)
        end

        # NOTE: Hear there be dragons. This is a prime location for plugin architecture to come along and expose a means for new work types
        # to register a conversion to attempt. But at least its isolated.
        #
        # Why are these placed in WorkConverters module? Because I want to separate the methods that find the object and the registered
        # location of those objects. By keeping them in separate namespaces, I don't have to worry about this module not being loaded.
        def self.instantiate_a_converter(work:, repository:)
          case work.work_type
          when Models::WorkType::DOCTORAL_DISSERTATION, Models::WorkType::MASTER_THESIS
            WorkConverters::EtdConverter
          when Models::WorkType::ULRA_SUBMISSION
            # NOTE: Locabulary gem for valid values
            case repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::AWARD_CATEGORY, cardinality: 1)
            when 'Senior Thesis'
              WorkConverters::UlraSeniorThesisConverter
            when '10000 Level', "20000–40000 Level", "Honors Thesis", "Capstone Project"
              WorkConverters::UlraDocumentConverter
            end
          end
        end
        private_class_method :instantiate_a_converter

        def self.default_repository
          Sipity::QueryRepository.new
        end
        private_class_method :default_repository
      end
    end
  end
end
