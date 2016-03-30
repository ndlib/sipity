require 'sipity/exceptions'
module Sipity
  module Conversions
    module ToRofHash
      # Responsible for allowing for different work types to be exported with custom metadata
      class WorkTypeConvertersForWork
        def self.build(work:, base_converter:, repository:)
          converter = instantiate_a_converter(work: work, base_converter: base_converter, repository: repository)
          raise Exceptions::FailedToInitializeWorkConverterError, work: work unless converter
          converter.new(work: work, base_converter: base_converter, repository: repository)
        end

        # NOTE: Hear there be dragons. This is a prime location for plugin architecture to come along and expose a means for new work types
        # to register a conversion to attempt. But at least its isolated.
        def self.instantiate_a_converter(work:, base_converter:, repository:)
          case work.work_type
          when Models::WorkType::DOCTORAL_DISSERTATION, Models::WorkType::MASTER_THESIS
            EtdConverter
          when Models::WorkType::ULRA_SUBMISSION
            # NOTE: Locabulary gem for valid values
            case repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::AWARD_CATEGORY, cardinality: 1)
            when 'Senior Thesis'
              UlraSeniorThesisConverter
            when '10000 Level', "20000–40000 Level", "Honors Thesis", "Capstone Project"
              UlraDocumentConverter
            end
          end
        end
        private_class_method :instantiate_a_converter

        # Responsible for defining the interface for the specific converters
        class AbstractConverter
          def initialize(work:, base_converter:, repository:)
            self.work = work
            self.base_converter = base_converter
            self.repository = repository
          end

          private

          attr_accessor :work, :base_converter, :repository

          public

          # def metadata
          #   raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          # end
          #
          # def rels_ext
          #   raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          # end
          #
          # def af_model
          #   raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          # end

          private

          # @todo Optimize round trips to the database concerning the additional attributes
          def fetch_attribute_values(key:)
            repository.work_attribute_values_for(work: work, key: key)
          end
        end
        private_constant :AbstractConverter

        # Responsible for exposing the custom metadata mapping that occurs for an ETD
        class EtdConverter < AbstractConverter
          def af_model
            'Etd'
          end

          # @todo dc:date for defense date looks very suspect
          def metadata
            {
              "@context" => jsonld_context,
              'dc:title' => work.title,
              'dc:creator' => fetch_attribute_values(key: 'author_name'),
              'dc:title#alternate' => fetch_attribute_values(key: 'alternate_title'),
              'dc:subject' => fetch_attribute_values(key: 'subject'),
              'dc:description#abstract' => fetch_attribute_values(key: 'abstract'),
              'dc:rights' => fetch_attribute_values(key: 'copyright'),
              'dc:language' => fetch_attribute_values(key: 'language'),
              'dc:date' => fetch_attribute_values(key: 'defense_date'),
              'dc:contributor' => collaborator_metadata,
              'ms:degree' => degree_metadata
            }
          end

          def rels_ext
            {
              "@context" => jsonld_context,
              'hydramata-rel:hasEditor' => [Figaro.env.curate_batch_user_pid!],
              'hydramata-rel:hasEditorGroup' => [Figaro.env.curate_grad_school_editing_group_pid!]
            }
          end

          private

          def jsonld_context
            {
              "dc" => 'http://purl.org/dc/terms/',
              "rdfs" => 'http://www.w3.org/2000/01/rdf-schema#',
              "ms" => 'http://www.ndltd.org/standards/metadata/etdms/1.1/',
              "ths" => 'http://id.loc.gov/vocabulary/relators/',
              "hydramata-rel" => "http://projecthydra.org/ns/relations#"
            }
          end

          def degree_metadata
            {
              'ms:name' => fetch_attribute_values(key: 'degree'),
              'ms:discipline' => fetch_attribute_values(key: 'program_name'),
              'ms:level' => etd_degree_level_from_work_type
            }
          end

          # @todo I cannot imagine that we really want dc:contributor to be nested within a dc:contributor data structure
          def collaborator_metadata
            work.collaborators.map do |collaborator|
              {
                'dc:contributor' => collaborator.name,
                'ms:role' => collaborator.role
              }
            end
          end

          def etd_degree_level_from_work_type
            # I could be using the translations, but under test this falls apart as I don't load the translations.
            # Loading translations adds a significant chunk of time to the test suite.
            {
              Models::WorkType::DOCTORAL_DISSERTATION => "Doctoral Dissertation",
              Models::WorkType::MASTER_THESIS => "Master’s Thesis"
            }.fetch(work.work_type)
          end
        end

        class UlraSeniorThesisConverter < AbstractConverter
        end

        class UlraDocumentConverter < AbstractConverter
        end
      end
    end
  end
end
