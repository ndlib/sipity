require 'sipity/conversions/to_rof/access_rights_builder'
require 'rof/rdf_context'

module Sipity
  module Conversions
    module ToRof
      # A namespacing module
      module WorkConverters
        # Responsible for defining the interface for the specific converters
        class CoreConverter
          DEFAULT_ROF_TYPE = 'fobject'.freeze
          def initialize(work:, repository: default_repository, attachment_converter: default_attachment_converter)
            self.work = work
            self.repository = repository
            self.attachment_converter = attachment_converter
          end

          private

          attr_writer :work
          attr_accessor :repository

          public

          # @api public
          attr_reader :work

          # @api public
          def namespaced_pid(context: work)
            "und:#{context.to_param}"
          end

          # @api public
          def to_rof
            [to_hash] + convert_attachments_to_array_of_rof_elements
          end

          # @api public
          # @return Hash
          def edit_groups
            raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          end

          # @api public
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

          # @return Hash
          def metadata
            raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          end

          # @return Array
          def attachments
            @attachments ||= Array.wrap(repository.work_attachments(work: work, predicate_name: :all, order: :representative_first))
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

          def representative_attachment
            repository.representative_attachment_for(work: work)
          end

          def properties
            text = "<fields><depositor>#{AccessRightsBuilder::BATCH_USER}</depositor>"
            the_representative_attachment = representative_attachment
            if the_representative_attachment
              text = "#{text}<representative>#{namespaced_pid(context: the_representative_attachment)}</representative>"
            end
            "#{text}</fields>"
          end

          def access_rights
            AccessRightsBuilder.to_hash(
              work: work,
              access_rights_data: work.access_right,
              repository: repository,
              edit_groups: edit_groups
            )
          end

          private

          def convert_attachments_to_array_of_rof_elements
            attachments.map do |attachment|
              attachment_converter.call(attachment: attachment, work_converter: self, repository: repository)
            end
          end

          attr_accessor :attachment_converter
          def default_attachment_converter
            ToRof::AttachmentConverter
          end

          # @todo Optimize round trips to the database concerning the additional attributes
          def fetch_attribute_values(key:, **keywords)
            repository.work_attribute_values_for(work: work, key: key, **keywords)
          end

          def default_repository
            Sipity::QueryRepository.new
          end

          def jsonld_context
            ROF::RdfContext
          end

          def format_date(date)
            date.strftime('%Y-%m-%d')
          end
        end
        private_constant :CoreConverter
      end
    end
  end
end
