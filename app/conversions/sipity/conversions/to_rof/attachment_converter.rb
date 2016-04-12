require 'sipity/conversions/to_rof/access_rights_builder'
module Sipity
  module Conversions
    module ToRof
      # Responsible for converting an attachment to an ROF hash.
      #
      # @see Sipity::Mappers::GenericFileMapper for the original work and inspiration.
      class AttachmentConverter
        # @api public
        #
        # @param attachment [Sipity::Models::Attachment]
        def self.call(attachment:, work_converter:, **keywords)
          new(attachment: attachment, work_converter: work_converter, **keywords).call
        end

        def initialize(attachment:, work_converter:, repository: default_repository)
          self.attachment = attachment
          self.repository = repository
          self.work_converter = work_converter
        end

        def call
          {
            'type' => 'fobject',
            'pid' => namespaced_pid(context: attachment),
            'af-model' => 'GenericFile',
            'rights' => access_rights,
            'metadata' => metadata,
            'rels-ext' => rels_ext,
            'properties-meta' => properties_meta,
            'properties' => properties,
            'content-meta' => content_meta,
            'content-file' => content_file
          }
        end

        private

        attr_accessor :attachment, :repository, :work_converter

        def default_repository
          Sipity::QueryRepository.new
        end

        extend Forwardable
        def_delegators :work_converter, :namespaced_pid, :edit_groups, :work

        def access_rights
          AccessRightsBuilder.to_hash(
            work: work,
            access_rights_data: attachment_access_rights_data,
            edit_groups: edit_groups,
            repository: repository
          )
        end

        def attachment_access_rights_data
          @attachment_access_rights_data ||= repository.attachment_access_right(attachment: attachment)
        end

        def metadata
          {
            "@context" => jsonld_contexts,
            "dc:title" => attachment.file_name,
            "dc:creator" => creator_usernames,
            "dc:date#created" => date_convert(attachment.created_at),
            "dc:modified" => date_convert(attachment.updated_at)
          }
        end

        def date_convert(input)
          input.to_date.strftime('%FZ')
        end

        def creator_usernames
          @creator_usernames ||= Array.wrap(
            repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER)
          ).map(&:username)
        end

        def rels_ext
          {
            "@context" => jsonld_contexts,
            'hydramata-rel:hasEditor' => [Figaro.env.curate_batch_user_pid!],
            'hydramata-rel:hasEditorGroup' => edit_groups,
            'isPartOf' => [namespaced_pid(context: work)]
          }
        end

        def jsonld_contexts
          {
            "dc" => 'http://purl.org/dc/terms/',
            "rdfs" => 'http://www.w3.org/2000/01/rdf-schema#'
          }
        end

        def properties_meta
          { 'mime-type' => 'text/xml' }
        end

        def properties
          "<fields><depositor>#{AccessRightsBuilder::BATCH_USER}</depositor></fields>"
        end

        def content_meta
          {
            'mime-type' => attachment.file.mime_type,
            'label' => attachment.file_name
          }
        end

        def content_file
          attachment.to_rof_file_basename
        end
      end
    end
  end
end
