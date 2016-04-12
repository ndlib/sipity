module Sipity
  module Models
    # Represents a single file attached to a given work.
    #
    # If you want to always fake having an attachment (i.e. you copied the production database to your local machine but did not copy
    # the production attachments from their filesystem) add the following to the class definition:
    #
    #      if Rails.env.development?
    #        after_initialize do |obj|
    #          obj.file = File.new(__FILE__)
    #        end
    #      end
    class Attachment < ActiveRecord::Base
      extend Dragonfly::Model
      self.table_name = 'sipity_attachments'
      self.primary_key = :pid

      validates :is_representative_file, uniqueness: { scope: :work_id }, if: :is_representative_file?

      alias_attribute :name, :file_name

      has_one :access_right, as: :entity, dependent: :destroy

      def to_s
        file_name
      end

      belongs_to :work
      dragonfly_accessor :file

      THUMBNAIL_HEIGHT = THUMBNAIL_WIDTH = '64'.freeze
      def thumbnail_url(width: THUMBNAIL_WIDTH, height: THUMBNAIL_HEIGHT)
        # `if file.image?` is the slow line; It fires up a command shell that runs identify
        if file.image?
          file.thumb("#{width}x#{height}#").url
        else
          extname = File.extname(file_name).sub(/^\./, '') + '.png'
          File.join(Dragonfly.app.server.url_host, 'extname_thumbnails', width, height, extname)
        end
      end

      delegate :url, :path, to: :file, prefix: :file, allow_nil: true

      def to_rof_file_basename
        "#{pid}-#{file_name}"
      end
    end
  end
end
