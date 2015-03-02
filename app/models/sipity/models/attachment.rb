module Sipity
  module Models
    # Represents a single file attached to a given work.
    class Attachment < ActiveRecord::Base
      extend Dragonfly::Model
      self.table_name = 'sipity_attachments'
      self.primary_key = :pid

      validates :is_representative_file, uniqueness: { scope: :work_id }, if: :is_representative_file?

      alias_attribute :name, :file_name

      def to_s
        file_name
      end

      belongs_to :work
      dragonfly_accessor :file

      THUMBNAIL_SIZE = '64x64#'.freeze
      def thumbnail_url(size = THUMBNAIL_SIZE)
        file.thumb(size).url
      end
    end
  end
end
