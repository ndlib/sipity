module Sipity
  module Conversions
    module ToRofHash
      # Responsible for converting an attachment to an ROF hash.
      #
      # @see Sipity::Mappers::GenericFileMapper for the original work and inspiration.
      class AttachmentConverter
        # @todo Extract this to a more generic location. Figaro perhaps?
        BATCH_USER = 'curate_batch_user'.freeze

        def self.call(attachment, **keywords)
          new(attachment, **keywords).call
        end

        def initialize(attachment, repository: default_repository)
          self.attachment = attachment
          self.repository = repository
        end

        def call
          {
            'type' => 'fobject',
            'pid' => pid,
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

        def pid(context: attachment)
          "und:#{context.id}"
        end

        def access_rights
          base_access_rights.merge(attachment_specific_access_rights)
        end

        def base_access_rights
          {
            'read' => creator_usernames,
            'edit' => [BATCH_USER],
            'edit-groups' => editing_groups
          }
        end

        def attachment_specific_access_rights
          case attachment_access_rights_data.access_right_code
          when Models::AccessRight::OPEN_ACCESS
            { 'read-groups' => 'public' }
          when Models::AccessRight::RESTRICTED_ACCESS
            { 'read-groups' => 'restricted' }
          when Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS
            { 'read-groups' => 'public', 'embargo-date' => attachment_access_rights_data.transition_date.strftime('%Y-%m-%d') }
          when Models::AccessRight::PRIVATE_ACCESS
            {}
          else
            raise "Unexpected AccessRight for #{attachment_access_rights_data.inspect}"
          end
        end

        def attachment_access_rights_data
          @attachment_access_rights_data ||= repository.attachment_access_right(attachment: attachment)
        end

        # @note This only applies to the ETD group; The editing group will need to be parameterized
        def editing_groups
          [Figaro.env.curate_grad_school_editing_group_pid!]
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

        extend Forwardable
        def_delegator :attachment, :work

        def creator_usernames
          @creator_usernames ||= Array.wrap(
            repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER)
          ).map(&:username)
        end

        def rels_ext
          {
            "@context" => jsonld_contexts,
            'hydramata-rel:hasEditor' => [Figaro.env.curate_batch_user_pid!],
            'hydramata-rel:hasEditorGroup' => [Figaro.env.curate_grad_school_editing_group_pid!],
            'isPartOf' => [pid(context: work)]
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
          "<fields><depositor>#{BATCH_USER}</depositor></fields>"
        end

        def content_meta
          {
            'mime-type' => attachment.file.mime_type,
            'label' => attachment.file_name
          }
        end

        def content_file
          "#{attachment.id}-#{attachment.file_name}"
        end

        attr_accessor :attachment, :repository

        def default_repository
          Sipity::QueryRepository.new
        end
      end
    end
  end
end
