module Sipity
  # :nodoc:
  module Mappers
    # Mapper to map etd work into descMetadata
    class UlraMapper
      CONTENT_MODEL_NAME = 'Ulra'.freeze
      NAMESPACE = 'und:'.freeze
      BATCH_USER = 'curate_batch_user'.freeze
      TERM_URI = {
        dc: 'http://purl.org/dc/terms/',
        rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
        ms: 'http://www.ndltd.org/standards/metadata/etdms/1.1/',
        ths: 'http://id.loc.gov/vocabulary/relators/'
      }.freeze

      WORK_ATTRIBUTES = ['alternate_title', 'subject', 'abstract', 'copyright', 'language', 'defense_date'].freeze
      PID_KEY = 'pid'.freeze
      TYPE_KEY = 'type'.freeze
      CONTEXT_KEY = '@context'.freeze
      AF_MODEL_KEY = 'af-model'.freeze
      DESC_METADATA_KEY = 'metadata'.freeze
      ACCESS_RIGHTS_KEY = 'rights'.freeze
      PROPERTIES_METADATA_KEY = 'properties-meta'.freeze
      PROPERTIES_KEY = 'properties'.freeze
      PUBLIC_ACCESS = 'public'.freeze
      ND_ONLY_ACCESS = 'restricted'.freeze
      READ_KEY = 'read'.freeze
      EDIT_KEY = 'edit'.freeze
      READ_GROUP_KEY = 'read-groups'.freeze
      EDIT_GROUP_KEY = 'edit-groups'.freeze
      EMBARGO_KEY = 'embargo-date'.freeze

      # RELS-EXT KEYS
      RELS_EXT_KEY = 'rels-ext'.freeze
      RELS_EXT_URI = {
        "hydramata-rel" => "http://projecthydra.org/ns/relations#"
      }.freeze
      EDITOR_PREDICATE_KEY = 'hydramata-rel:hasEditor'.freeze
      EDITOR_GROUP_PREDICATE_KEY = 'hydramata-rel:hasEditorGroup'.freeze

      def self.call(work, **keywords)
        new(work, **keywords).call
      end

      def initialize(work, mount_data_path: default_mount_data_path, repository: default_repository, attribute_map: default_attribute_map)
        self.work = work
        self.repository = repository
        self.attribute_map = attribute_map
        self.mount_data_path = mount_data_path
      end

      def call
        build_json
      end

      private

      attr_accessor :work, :repository, :attribute_map, :mount_data_path

      def build_json
        Jbuilder.encode do |json|
          gather_work_metadata(json)
          json.set!(ACCESS_RIGHTS_KEY, decode_access_right)
          transform_attributes_to_metadata(json)
          rels_ext_datastream(json)
          json.set! PROPERTIES_METADATA_KEY.to_sym do
            json.set!('mime-type', 'text/xml')
          end
          json.set!(PROPERTIES_KEY, "<fields><depositor>#{BATCH_USER}</depositor></fields>")
        end
      end

      def namespaced_pid
        NAMESPACE + work.id
      end

      def attributes
        attributes = {}
        WORK_ATTRIBUTES.each do |k|
          attributes[k] = repository.work_attribute_values_for(work: work, key: k)
        end
        attributes
      end

      def metadata
        metadata = attributes
        metadata['title'] = work.title
        metadata['contributor'] = collaborators_name_and_title
        metadata['degree'] = degree_info
        metadata['creator'] = creator_names
        metadata
      end

      def degree_info
        degree_info = {}
        degree_info[extract_name_for('degree_name')] = repository.work_attribute_values_for(work: work, key: 'degree')
        degree_info[extract_name_for('program_name')] = repository.work_attribute_values_for(work: work, key: 'program_name')
        degree_info[extract_name_for('degree_level')] = lookup_degree_level_for(work: work)
        degree_info
      end

      def lookup_degree_level_for(work:)
        I18n.t("#{work.work_type}.label", scope: 'work_types', raise: true)
      end

      def collaborators
        work.collaborators
      end

      def collaborators_name_and_title
        collaborators_name_and_title = []
        collaborators.map do |collaborator|
          name_and_title_hash = {}
          name_and_title_hash[extract_name_for('contributor')] = collaborator.name
          name_and_title_hash[extract_name_for('contributor_role')] = collaborator.role
          collaborators_name_and_title << name_and_title_hash
        end
        collaborators_name_and_title
      end

      def access_right
        @access_right ||= repository.work_access_right_code(work: work)
      end

      def creator_names
        repository.work_attribute_values_for(work: work, key: 'author_name')
      end

      def creator_usernames
        repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER).map(&:username)
      end

      def gather_work_metadata(json)
        json.set!(TYPE_KEY, "fobject")
        json.set!(PID_KEY, namespaced_pid)
        json.set!(AF_MODEL_KEY, CONTENT_MODEL_NAME)
      end

      def transform_attributes_to_metadata(json)
        json.set! DESC_METADATA_KEY do
          json.set! CONTEXT_KEY do
            TERM_URI.each { |key, uri| json.set!(key, uri) }
          end
          metadata.each do |key, value|
            json.set!(extract_name_for(key), value)
          end
        end
      end

      def rels_ext_datastream(json)
        json.set! RELS_EXT_KEY do
          json.set! CONTEXT_KEY do
            RELS_EXT_URI.each { |key, uri| json.set!(key, uri) }
          end
          json.set!(EDITOR_PREDICATE_KEY, [Figaro.env.curate_batch_user_pid!])
          json.set!(EDITOR_GROUP_PREDICATE_KEY, [Figaro.env.curate_grad_school_editing_group_pid!])
        end
      end

      def decode_access_right
        # determine and add Public, Private, Embargo and ND only rights
        decoded_access_rights = {
          READ_KEY => creator_usernames, EDIT_KEY => [BATCH_USER], EDIT_GROUP_KEY => [Figaro.env.curate_grad_school_editing_group_pid!]
        }
        case access_right
        when Models::AccessRight::OPEN_ACCESS
          decoded_access_rights[READ_GROUP_KEY] = [PUBLIC_ACCESS]
        when Models::AccessRight::RESTRICTED_ACCESS
          decoded_access_rights[READ_GROUP_KEY] = [ND_ONLY_ACCESS]
        when Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS
          decoded_access_rights[READ_GROUP_KEY] = [PUBLIC_ACCESS]
          decoded_access_rights[EMBARGO_KEY] = embargo_date
        when Models::AccessRight::PRIVATE_ACCESS
        end
        decoded_access_rights
      end

      def embargo_date
        embargo_dt = work.access_right.transition_date
        embargo_dt.strftime('%Y-%m-%d')
      end

      def extract_name_for(attribute)
        attribute_map.fetch(attribute.to_sym)
      end

      def default_attribute_map
        require 'sipity/exporters/etd_exporter' unless defined?(Exporters::UlraExporter::ULRA_ATTRIBUTES)
        Exporters::UlraExporter::ULRA_ATTRIBUTES
      end

      def default_mount_data_path
        require 'sipity/exporters/etd_exporter' unless defined?(Exporters::UlraExporter::MNT_DATA_PATH)
        Exporters::UlraExporter::MNT_DATA_PATH
      end

      def default_repository
        QueryRepository.new
      end
    end
  end
end
