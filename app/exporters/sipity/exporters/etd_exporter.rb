module Sipity
  # :nodoc:
  module Exporters
    # Export work from Sipity to Curate, create ROF file and download attachments
    # and bundle them to directory
    class EtdExporter
      ROF_FILE_PREFIX = 'metadata-'.freeze
      ROF_FILE_EXTN = '.rof'.freeze
      MNT_DATA_PATH = Figaro.env.curate_batch_data_mount_path!
      MNT_QUEUE_PATH = Figaro.env.curate_batch_queue_mount_path!
      ETD_ATTRIBUTES = {
        creator: "dc:creator",
        title: "dc:title",
        alternate_title: "dc:title#alternate",
        subject: "dc:subject",
        abstract: "dc:description#abstract",
        country: "dc:publisher#country",
        advisor: "ths:relators",
        contributor: "dc:contributor",
        contributor_role: "ms:role",
        date_created: "dc:date#created",
        date_uploaded: "dc:dateSubmitted",
        date_modified: "dc:modified",
        language: "dc:language",
        copyright: "dc:rights",
        note: "dc:description#note",
        publisher: "dc:publisher",
        temporal_coverage: "dc:coverage#temporal",
        spatial_coverage: "dc:coverage#spatial",
        identifier: "dc:identifier#doi",
        urn: "dc:identifier#other",
        defense_date: "dc:date",
        date_approved: "dc:date#approved",
        degree: "ms:degree",
        degree_name: "ms:name",
        program_name: "ms:discipline",
        degree_level: "ms:level"
      }.freeze

      def self.call(work)
        new(work).call
      end

      def self.queue_pathname_for(work:, base_path: MNT_QUEUE_PATH)
        Pathname.new(File.join(base_path, "/sipity-#{work.id}"))
      end

      def initialize(work, repository: default_repository, work_mapper: default_work_mapper, attachment_mapper: default_attachment_mapper)
        self.work = work
        self.repository = repository
        self.work_mapper = work_mapper
        self.attachment_mapper = attachment_mapper
        self.attachments = repository.work_attachments(work: work)
      end

      def call
        package_data
        create_webook
        move_files_to_curate_batch_queue
      end

      def export_to_json
        json_array = []
        json_array << work_mapper.call(work)
        # build attachment json
        attachments.each do |file|
          json_array << attachment_mapper.call(file)
        end
        json_array
      end

      private

      attr_accessor :work, :attachments

      def create_webook
        create_directory(curate_data_directory)
        File.open(File.join(curate_data_directory, 'WEBHOOK'), 'w+') do |file|
          file.puts(webhook_url)
        end
      end

      # @TODO This is likely in the wrong place but its what I have.
      def webhook_url
        File.join(
          "#{Figaro.env.protocol!}://#{webhook_authorization_credentials}@#{Figaro.env.domain_name!}",
          "/work_submissions/#{work.to_param}/callback/ingest_completed.json"
        )
      end

      def webhook_authorization_credentials
        "#{Sipity::Models::Group::BATCH_INGESTORS}:#{Figaro.env.sipity_batch_ingester_access_key!}"
      end

      def package_data
        # Create rof etd file to be ingested
        create_directory(curate_data_directory)
        file_name = ROF_FILE_PREFIX + work.id + ROF_FILE_EXTN
        metadata_file = File.join(curate_data_directory, file_name)
        File.open(metadata_file, 'w+') do |rof_file|
          rof_file.puts '[' + export_to_json.join(',') + ']'
        end
      end

      def move_files_to_curate_batch_queue
        create_directory(MNT_QUEUE_PATH)
        FileUtils.mv(curate_data_directory, File.join(MNT_QUEUE_PATH, '/'), verbose: true)
      end

      def curate_data_directory
        File.join(MNT_DATA_PATH, "/sipity-#{work.id}")
      end

      def create_directory(directory)
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
      end

      attr_accessor :repository

      def default_repository
        QueryRepository.new
      end

      attr_accessor :work_mapper

      def default_work_mapper
        -> (work) { Mappers::EtdMapper.call(work, attribute_map: ETD_ATTRIBUTES, mount_data_path: MNT_DATA_PATH) }
      end

      attr_accessor :attachment_mapper

      def default_attachment_mapper
        -> (attachment) { Mappers::GenericFileMapper.call(attachment, attribute_map: ETD_ATTRIBUTES, mount_data_path: MNT_DATA_PATH) }
      end
    end
  end
end
