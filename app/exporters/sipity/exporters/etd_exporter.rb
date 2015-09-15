require 'optparse'
module Sipity
  # :nodoc:
  module Exporters
    # Export work from Sipity to Curate, create ROF file and download attachments
    # and bundle them to directory
    class EtdExporter
      ROF_FILE_PREFIX = 'metadata-'.freeze
      ROF_FILE_EXTN = '.rof'.freeze
      MNT_DATA_PATH = Pathname(Figaro.env.curate_batch_mnt_path) + "../../data/sipity"
      MNT_QUEUE_PATH = "#{Figaro.env.curate_batch_mnt_path}/queue"
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
      }

      def self.etd_attributes
        ETD_ATTRIBUTES
      end

      def self.call(work)
        new(work).call
      end

      def initialize(work, repository: default_repository)
        self.work = work
        self.repository = repository
        self.attachments = repository.work_attachments(work: work)
      end

      def call
        package_data
        move_files_to_curate_batch_queue
      end

      def export_to_json
        json_array = []
        json_array << Mappers::EtdMapper.call(work)
        # build attachment json
        attachments.each do |file|
          json_array << Mappers::GenericFileMapper.call(file)
        end
        json_array
      end

      private

      attr_accessor :repository, :work, :attachments

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
        FileUtils.mv(curate_data_directory, MNT_QUEUE_PATH, verbose: true)
      end

      def curate_data_directory
        "#{MNT_DATA_PATH}/sipity-#{work.id}"
      end

      def create_directory(directory)
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
      end

      def default_repository
        QueryRepository.new
      end
    end
  end
end
