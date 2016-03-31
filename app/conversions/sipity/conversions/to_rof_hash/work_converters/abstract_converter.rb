require 'sipity/conversions/to_rof_hash/access_rights_builder'

module Sipity
  module Conversions
    module ToRofHash
      # A namespacing module
      module WorkConverters
        # Responsible for defining the interface for the specific converters
        class AbstractConverter
          DEFAULT_ROF_TYPE = 'fobject'.freeze
          def initialize(work:, repository: default_repository)
            self.work = work
            self.repository = repository
          end

          private

          attr_accessor :work, :repository

          public

          def to_hash
            {
              'type' => rof_type,
              'pid' => namespaced_pid,
              'af-model' => af_model,
              'metadata' => metadata,
              'rels-ext' => rels_ext,
              'rights' => access_rights,
              'properties-meta' => properties_meta,
              'properties' => properties
            }
          end

          def rof_type
            DEFAULT_ROF_TYPE
          end

          def namespaced_pid
            "und:#{work.to_param}"
          end

          # @return Hash
          def metadata
            raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          end

          # @return Array
          def attachments
            raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          end

          # @return Hash
          def rels_ext
            raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          end

          # @return String
          def af_model
            raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          end

          def properties_meta
            { 'mime-type' => 'text/xml' }
          end

          def properties
            "<fields><depositor>#{AccessRightsBuilder::BATCH_USER}</depositor></fields>"
          end

          def access_rights
            AccessRightsBuilder.call(
              work: work,
              access_rights_data: work.access_right,
              repository: repository,
              edit_groups: edit_groups
            )
          end

          # @return Hash
          def edit_groups
            raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          end

          private

          # @todo Optimize round trips to the database concerning the additional attributes
          def fetch_attribute_values(key:)
            repository.work_attribute_values_for(work: work, key: key)
          end

          def default_repository
            Sipity::QueryRepository.new
          end

          def jsonld_context
            {
              "dc" => 'http://purl.org/dc/terms/',
              "rdfs" => 'http://www.w3.org/2000/01/rdf-schema#',
              "ms" => 'http://www.ndltd.org/standards/metadata/etdms/1.1/',
              "ths" => 'http://id.loc.gov/vocabulary/relators/',
              "hydramata-rel" => "http://projecthydra.org/ns/relations#"
            }
          end

          def format_date(date)
            date.strftime('%Y-%m-%d')
          end
        end
        private_constant :AbstractConverter
      end
    end
  end
end
