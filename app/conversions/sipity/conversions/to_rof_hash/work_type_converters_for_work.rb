module Sipity
  module Conversions
    module ToRofHash
      # Responsible for allowing for different work types to be exported with custom metadata
      module WorkTypeConvertersForWork
        CONVERTER_MAP = {
          Models::WorkType::DOCTORAL_DISSERTATION => 'EtdConverter'.freeze,
          Models::WorkType::MASTER_THESIS => 'EtdConverter'.freeze,
          Models::WorkType::ULRA_SUBMISSION => 'UlraConverter'.freeze
        }.freeze
        def self.build(work:, base_converter:, repository:)
          class_name = CONVERTER_MAP.fetch(work.work_type)
          const_get(class_name).new(work: work, base_converter: base_converter, repository: repository)
        end

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

          # @todo Optimize round trips to the database concerning the additional attributes
          def fetch_attribute_values(key:)
            repository.work_attribute_values_for(work: work, key: key)
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

        # A placeholder
        class UlraConverter < AbstractConverter
        end
      end
    end
  end
end
