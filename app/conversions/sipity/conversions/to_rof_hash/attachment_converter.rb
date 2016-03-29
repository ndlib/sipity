module Sipity
  module Conversions
    module ToRofHash
      # Responsible for converting an attachment to an ROF hash
      #
      # @see Sipity::Mappers::GenericFileMapper for inspiration
      class AttachmentConverter
        def self.call(attachment)
          new(attachment).call
        end

        def initialize(attachment)
          self.attachment = attachment
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

        def pid
          "und:#{attachment.id}"
        end

        def access_rights
          {}
        end

        def metadata
          {}
        end

        def rels_ext
          {}
        end

        def properties_meta
          {}
        end

        def properties
          {}
        end

        def content_meta
          {}
        end

        def content_file
          {}
        end

        attr_accessor :attachment
      end
    end
  end
end
