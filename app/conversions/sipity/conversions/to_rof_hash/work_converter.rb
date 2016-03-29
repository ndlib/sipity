module Sipity
  module Conversions
    module ToRofHash
      # Responsible for converting a work to an ROF hash. This is a bit more
      # complicated as the work's work_type defines the data structure.
      class WorkConverter
        # @api public
        #
        # @param attachment [Sipity::Models::Attachment]
        def self.call(work:, **keywords)
          new(work: work, **keywords).call
        end

        def initialize(work:, repository: default_repository)
          self.work = work
          self.repository = repository
        end

        private

        attr_accessor :work, :repository

        def default_repository
          Sipity::QueryRepository.new
        end

        public

        def call
          {
            'type' => 'fobject',
            'pid' => namespaced_pid(context: work),
            'af-model' => af_model,
            'rights' => access_rights,
            'metadata' => metadata,
            'rels-ext' => rels_ext,
            'properties-meta' => properties_meta,
            'properties' => properties
          }
        end

        private

        def namespaced_pid(context: work)
          "und:#{context.id}"
        end

        def af_model
          # Consider a PowerConverter? What is the rules for this?
          'Etd'
        end

        def access_rights
          AccessRightsBuilder.call(work: work, access_rights_data: work.access_right, repository: repository)
        end

        def metadata
          {
            "@context" => jsonld_context
          }.merge(specific_metadata_builder)
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

        # @todo dc:date for defense date looks very suspect
        def specific_metadata_builder
          {
            'dc:title' => work.title,
            'dc:creator' => fetch_attribute_values(key: 'author_name'),
            'dc:title#alternate' => fetch_attribute_values(key: 'alternate_title'),
            'dc:subject' => fetch_attribute_values(key: 'subject'),
            'dc:description#abstract' => fetch_attribute_values(key: 'abstract'),
            'dc:rights' => fetch_attribute_values(key: 'copyright'),
            'dc:language' => fetch_attribute_values(key: 'language'),
            'dc:date' => fetch_attribute_values(key: 'defense_date'),
            'dc:contributor' => nil,
            'ms:degree' => build_etd_degree_metadata
          }
        end

        # @todo Optimize round trips to the database concerning the additional attributes
        def fetch_attribute_values(key:)
          repository.work_attribute_values_for(work: work, key: key)
        end

        def build_etd_degree_metadata
          {
            'ms:name' => fetch_attribute_values(key: 'degree'),
            'ms:discipline' => fetch_attribute_values(key: 'program_name'),
            'ms:level' => etd_degree_level_from_work_type
          }
        end

        def etd_degree_level_from_work_type
          # I could be using the translations, but under test this falls apart as I don't load the translations.
          # Loading translations adds a significant chunk of time to the test suite.
          {
            Models::WorkType::DOCTORAL_DISSERTATION => "Doctoral Dissertation",
            Models::WorkType::MASTER_THESIS => "Master’s Thesis"
          }.fetch(work.work_type)
        end

        def rels_ext
          {
            "@context" => jsonld_context,
            'hydramata-rel:hasEditor' => [Figaro.env.curate_batch_user_pid!],
            'hydramata-rel:hasEditorGroup' => [Figaro.env.curate_grad_school_editing_group_pid!]
          }
        end

        def properties_meta
          { 'mime-type' => 'text/xml' }
        end

        def properties
          "<fields><depositor>#{AccessRightsBuilder::BATCH_USER}</depositor></fields>"
        end
      end
    end
  end
end
