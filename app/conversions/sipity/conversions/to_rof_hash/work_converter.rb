require 'sipity/conversions/to_rof_hash/specific_work_converters'
require 'sipity/conversions/to_rof_hash/access_rights_builder'
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
          self.specific_work_converter = SpecificWorkConverters.find_and_initialize(work: work, repository: repository)
        end

        private

        attr_accessor :work, :repository

        # Responsible for the custom conversions that happen based on the nuances of the work
        attr_accessor :specific_work_converter

        def default_repository
          Sipity::QueryRepository.new
        end

        public

        def call
          {
            'type' => 'fobject',
            'pid' => namespaced_pid(context: work),
            'af-model' => specific_work_converter.af_model,
            'metadata' => specific_work_converter.metadata,
            'rels-ext' => specific_work_converter.rels_ext,
            'rights' => access_rights,
            'properties-meta' => properties_meta,
            'properties' => properties
          }
        end

        private

        def namespaced_pid(context: work)
          "und:#{context.id}"
        end

        def access_rights
          AccessRightsBuilder.call(work: work, access_rights_data: work.access_right, repository: repository)
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
