require 'sipity/guard_interface_expectation'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    # This class is responsible for handling much of the form composition
    # regarding processing actions.
    #
    # Its my effort to break the inheritance cycle.
    class ProcessingForm
      # Code that writes code; Here is a configuration macro to help ensure we
      # have a common shape to all of our forms. Of particular note, it creates
      # some contract enforcement.
      #
      # @param form_class [Object] The class that we are going to use as a form
      #   for processing and validating user input.
      # @param base_class [ActiveRecord::Base] What is the underlying "concept"
      #   that this form is working on (i.e. Models::Work,
      #   Models::SubmissionWindow, etc.)
      # @param attribute_names [Array<Symbol>, Symbol] A convenience method for
      #   creating public reader/private writer methods for each of the named
      #   attributes.
      # @param keywords [Hash{Sybmol=>Object}] Additional keywords that can be
      #   used to overwrite.
      # @option keywords [Symbol] :processing_subject_name the name that we will
      #   be using to store the instance of underlying "concept". Another way to
      #   to think of it; When you go to submit the attributes via a web form,
      #   what is the hash key of the attributes (i.e. `work: { title: 'Mine'}`)
      # @option keywords [Class] :policy_enforcer the name of the Policy class
      #   responsible for enforcement. If none is given, one is derived from the
      #   other configuration options (see implementation)
      # @option keywords [String] :template the name of the template that will
      #   be used to render the web form. If none is given, one is derived from
      #   the other configuration options (see implementation)
      # @option keywords [Class] :processing_action_form_builder the form
      #   builder that you want to use. By default it is this class (i.e.
      #   Sipity::Forms::ProcessingForm). Included for dependency injection and
      #   future considerations.
      #
      # @note This method builds the interface and provides the interface
      #   validations via the GuardInterfaceExpectation module
      def self.configure(form_class:, base_class:, attribute_names:, **keywords)
        processing_form_class = self
        form_class.module_exec do
          class_attribute(:attribute_names, instance_writer: :false) unless respond_to?(:attribute_names=)
          self.attribute_names = Array.wrap(attribute_names)

          class_attribute(:processing_subject_name, instance_writer: :false) unless respond_to?(:processing_subject_name=)
          self.processing_subject_name = keywords.fetch(:processing_subject_name) do
            base_class.name.sub(/.*::(\w+)::(\w+)\Z/, '\2').underscore
          end

          class_attribute(:processing_action_form_builder, instance_writer: :false) unless respond_to?(:processing_action_form_builder=)
          self.processing_action_form_builder = keywords.fetch(:processing_action_form_builder) { processing_form_class }

          class_attribute :base_class unless respond_to?(:base_class=)
          self.base_class = base_class

          class_attribute :policy_enforcer unless respond_to?(:policy_enforcer=)
          self.policy_enforcer = keywords.fetch(:policy_enforcer) do
            base_class.name.sub(/::(\w+)::(\w+)\Z/, '::Policies::\2Policy').constantize
          end

          class_attribute :template unless respond_to?(:template=)
          self.template = keywords.fetch(:template) { name.demodulize.sub(/Form\Z/, '').underscore }

          class << self
            delegate :model_name, :human_attribute_name, to: :base_class
            private(:attribute_names=)
          end

          delegate(
            :to_processing_entity, :to_processing_action, :to_work_area, :repository, :processing_action_name, :translate,
            to: :processing_action_form
          )
          private :repository
          delegate :model_name, to: :base_class
          delegate(:param_key, to: :model_name)

          private

          attr_reader :processing_action_form

          public

          attr_accessor(*Array.wrap(attribute_names))
          attr_accessor :requested_by, processing_subject_name
          alias_method :entity, processing_subject_name

          define_method :persisted? do
            false
          end

          include GuardInterfaceExpectation
          define_method :processing_action_form= do |input|
            guard_interface_expectation!(
              input, :submit, :repository, :translate, :to_processing_entity, :to_processing_action, :processing_action_name, :to_work_area
            )
            @processing_action_form = input
          end
        end
      end

      def initialize(form:, repository: default_repository, translator: default_translator, **keywords)
        self.form = form
        self.repository = repository
        self.translator = translator
        self.processing_action_name = keywords.fetch(:processing_action_name) { default_processing_action_name }
      end

      delegate :valid?, :entity, to: :form

      def submit(requested_by: form.requested_by)
        return false unless valid?
        yield if block_given?
        repository.register_action_taken_on_entity(entity: entity, action: to_processing_action, requested_by: requested_by)
        repository.update_processing_state!(entity: entity, to: to_processing_action.resulting_strategy_state)
        entity
      end

      attr_reader :repository, :processing_action_name, :translator

      def to_processing_entity
        Conversions::ConvertToProcessingEntity.call(entity)
      end

      def to_work_area
        PowerConverter.convert(entity, to: :work_area)
      end

      def to_processing_action
        Conversions::ConvertToProcessingAction.call(processing_action_name, scope: entity)
      end

      def translate(identifier, scope: default_translation_scope, predicate: :label)
        translator.call(scope: scope, subject: entity, object: identifier, predicate: predicate)
      end

      private

      def default_translation_scope
        "processing_actions.#{processing_action_name}"
      end

      attr_writer :repository, :processing_action_name
      attr_reader :form

      def default_repository
        CommandRepository.new
      end

      def translator=(input)
        guard_interface_expectation!(input, :call)
        @translator = input
      end

      def default_translator
        Controllers::TranslationAssistant
      end

      FORM_METHOD_NAMES_FOR_INTERFACE = [
        :valid?, :errors, :base_class, :requested_by, :entity, :model_name, :param_key, :processing_action_name, :translate, :template
      ].freeze
      FORM_METHOD_NAMES_FOR_COERCION = [:to_processing_entity, :to_processing_action, :to_work_area].freeze

      include GuardInterfaceExpectation
      def form=(input)
        guard_interface_expectation!(input, FORM_METHOD_NAMES_FOR_INTERFACE)
        guard_interface_expectation!(input, FORM_METHOD_NAMES_FOR_COERCION, include_all: true)
        guard_interface_collaborator_expectations!(input, requested_by: :present?)
        @form = input
      end

      def default_processing_action_name
        form.class.name.demodulize.sub(/Form\Z/, '').underscore
      end
    end
  end
end
