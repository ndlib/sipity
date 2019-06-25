module Sipity
  module DataGenerators
    # Responsible for the generation of a submission window and its corresponding processing entries (i.e. state machine, emails ,etc.)
    class SubmissionWindowGenerator
      def self.generate_from_json_file(path:, **keywords)
        contents = path.respond_to?(:read) ? path.read : File.read(path)
        data = JSON.parse(contents)
        new(data: data, **keywords).call
      end

      class << self
        alias call  generate_from_json_file
      end

      # @param work_area [Sipity::Models::WorkArea]
      # @param data [#deep_symbolize_keys] the configuration information from which we will generate all the data entries
      # @param schema [#call] The schema in which you will validate the data
      # @param validator [#call] The validation service for the given data and schema
      def initialize(work_area:, data:, schema: default_schema, validator: default_validator)
        self.work_area = work_area
        self.data = data
        self.schema = schema
        self.validator = validator
        validate!
      end

      private

      attr_reader :work_area

      def work_area=(input)
        @work_area = PowerConverter.convert(input, to: :work_area)
      end

      attr_reader :data

      def data=(input)
        @data = input.deep_symbolize_keys
      end

      attr_accessor :validator

      def default_validator
        SchemaValidator.method(:call)
      end

      attr_accessor :schema

      def default_schema
        SubmissionWindowSchema
      end

      def validate!
        validator.call(data: data, schema: schema)
      end

      public

      def call
        Array.wrap(data.fetch(:submission_windows)).each do |configuration|
          find_or_create_from(configuration: configuration)
        end
      end

      def find_or_create_from(configuration:)
        submission_window = create_submission_window!(attributes: configuration.fetch(:attributes))
        strategy = find_or_resuse_or_create_processing_strategy!(submission_window: submission_window)
        find_or_create_submission_windows_processing_entity!(submission_window: submission_window, strategy: strategy)
        find_or_create_strategy_permissions!(
          strategy: strategy, strategy_permissions_configuration: configuration.fetch(:strategy_permissions, [])
        )
        generate_state_diagram(strategy: strategy, actions_configuration: configuration.fetch(:actions))
        build_work_types_for(submission_window: submission_window, work_type_config_paths: configuration.fetch(:work_type_config_paths))
      end

      def find_or_resuse_or_create_processing_strategy!(submission_window:)
        return submission_window.processing_strategy if submission_window.processing_strategy
        strategy_usage = Models::Processing::StrategyUsage.where(
          usage_id: work_area.submission_window_ids, usage_type: PowerConverter.convert(submission_window, to: :polymorphic_type)
        ).first
        return strategy_usage.strategy if strategy_usage
        strategy = Models::Processing::Strategy.find_or_create_by!(
            name: "Submission Window #{work_area.slug} #{submission_window.slug} processing"
        )
        return strategy
      end

      def find_or_create_submission_windows_processing_entity!(strategy:, submission_window:)
        submission_window.processing_entity || submission_window.create_processing_entity!(
          strategy: strategy, strategy_state: strategy.initial_strategy_state
        )
        Models::Processing::StrategyUsage.find_or_create_by!(strategy: strategy, usage: submission_window)
      end

      def create_submission_window!(attributes:)
        slug = PowerConverter.convert(attributes.fetch(:slug), to: :slug)
        window = Models::SubmissionWindow.find_or_create_by!(work_area_id: work_area.id, slug: slug)
        return window if window.attributes.symbolize_keys.slice(*attributes.keys) == attributes
        window.update(attributes)
        window
      end

      extend Forwardable
      def_delegator StrategyPermissionsGenerator, :call, :find_or_create_strategy_permissions!
      def_delegator ProcessingActionsGenerator, :call, :generate_state_diagram

      def build_work_types_for(submission_window:, work_type_config_paths:)
        Array.wrap(work_type_config_paths).each do |path|
          WorkTypeGenerator.generate_from_json_file(submission_window: submission_window, path: Rails.root.join(path))
        end
      end
    end
  end
end
