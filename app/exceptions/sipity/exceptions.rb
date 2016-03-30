require 'active_support/core_ext/array/wrap'

module Sipity
  # The logical container for all things Exceptional in Sipity! And by
  # Exceptional, I mean custom exceptions that can and will be raised by Sipity.
  #
  # By focusing on custom exceptions, the Application's exception handling can
  # become much more granular.
  module Exceptions
    # Creating a base exception to further extend.
    class RuntimeError < ::RuntimeError
    end

    # When you can't instantiate a specific work converter, raise this exception.
    class FailedToInitializeWorkConverterError < RuntimeError
      attr_reader :work
      def initialize(work:)
        @work = work
        super("Failed to initialize work converter for #{work.inspect}")
      end
    end

    # When a schema doesn't validate
    class InvalidSchemaError < RuntimeError
      attr_reader :errors
      def initialize(errors:)
        @errors = errors
        super("Invalid schema: #{errors.inspect}")
      end
    end

    # When you have misconfigured the email options
    class EmailAsOptionInvalidError < RuntimeError
      def initialize(as:, valid_list:)
        super("Invalid :as option for email notifier, #{as.inspect} is not in #{valid_list.inspect}")
      end
    end

    # When passing parameters through the job layer, passing complex objects
    # can cause problems; In that we don't want to pass state across the async
    # boundary.
    class NonPrimativeParameterError < RuntimeError
    end

    # Responsible for conveying the erroring information when there is an error.
    class ResponseHandlerError < RuntimeError
      attr_reader :object, :status, :errors
      def initialize(object:, errors:, status:)
        @object = object
        @errors = errors
        @status = status
        super(%(Encountered status="#{status}" for object="#{object}"\n\terrors=#{Array.wrap(errors).to_sentence}))
      end
    end

    # Uh oh! It looks like our response handler didn't know what to do.
    class UnhandledResponseError < RuntimeError
      def initialize(handler)
        super("Expected to be able to handle #{handler.inspect}.")
      end
    end

    # This is not a defined resourceful action
    class UnprocessableResourcefulActionNameError < RuntimeError
      def initialize(container:, object:)
        super("Expected #{object} to have a #name that is within #{container}")
      end
    end

    # The object did not implement the expected interface.
    class InterfaceExpectationError < RuntimeError
      def initialize(object:, expectations:)
        self.expectations = expectations
        super("Expected #{object} to implement #{expected_methods}")
      end

      private

      def expected_methods
        @expectations.map { |e| "##{e}" }.inspect
      end

      def expectations=(input)
        @expectations = Array.wrap(input)
      end
    end

    # The object did not implement the expected interface.
    class InterfaceCollaboratorExpectationError < RuntimeError
      def initialize(object:, collaborator_expectations:)
        self.collaborator_expectations = collaborator_expectations
        super("Expected #{object} to collaborate #{expected_methods}")
      end

      private

      def expected_methods
        @collaborator_expectations.map(&:inspect).inspect
      end

      def collaborator_expectations=(input)
        @collaborator_expectations = Array.wrap(input)
      end
    end

    # Indicates that the returned value from the runner was incorrectly built.
    class InvalidHandledResponseStatus < RuntimeError
      def initialize(input, expected_class: Symbol)
        super("Expected #{input} to be a #{expected_class}; It was a #{input.class}")
      end
    end

    # When you go about building an object that has method missing expectations
    # you may need to raise an exception if you are planning to catch a
    # method_name via message missing, but won't because the method is already
    # defined.
    class ExistingMethodsAlreadyDefined < RuntimeError
      def initialize(context, method_names)
        super("#{context} implemented the following methods: #{method_names.inspect}. #{context} won't work as expected")
      end
    end

    # An abstract conversion error
    class ConversionError < RuntimeError
      class_attribute :conversion_target, instance_writer: false
      self.conversion_target = '<Undefined Target>'

      def initialize(attempted_conversion_object)
        super("Unable to convert #{attempted_conversion_object.inspect} to a #{conversion_target}")
      end
    end

    # Unable to convert the given object into a permanent URI
    class PermanentUriConversionError < ConversionError
      self.conversion_target = 'PermanentURI'
    end

    # Unable to convert the given object into an entity type
    class EntityTypeConversionError < ConversionError
      self.conversion_target = 'EntityType'
    end

    # Unable to convert the given object into a Role
    class RoleConversionError < ConversionError
      self.conversion_target = 'Models::Role'
    end

    # Unable to convert the given object into a Date
    class DateConversionError < ConversionError
      self.conversion_target = 'Date'
    end

    # Unable to convert the given object into a EntityActionRegister
    class RegisteredActionConversionError < ConversionError
      self.conversion_target = 'Models::Processing::EntityActionRegister'
    end

    # Processing Conversion Errors; These may often mean a database entry is
    # missing.
    class ProcessingConversionError < ConversionError
    end

    # Unable to convert the given object into a processing entity
    class ProcessingEntityConversionError < ProcessingConversionError
      self.conversion_target = 'Models::Processing::Entity'
    end

    # Unable to convert the given object into a processing actor
    class ProcessingActorConversionError < ProcessingConversionError
      self.conversion_target = 'Models::Processing::Actor'
    end

    # Unable to convert the given object into a processing strategy id
    class ProcessingStrategyIdConversionError < ProcessingConversionError
      self.conversion_target = 'Models::Processing::Strategy#id'
    end

    # Unable to convert the given object into a processing strategy action
    class ProcessingStrategyActionConversionError < ProcessingConversionError
      self.conversion_target = 'Models::Processing::StrategyAction'
    end

    # Unable to convert the given object into a processing strategy action
    class ProcessingActionNameConversionError < ProcessingConversionError
      self.conversion_target = 'Models::Processing::StrategyAction#name'
    end

    # Unable to convert the given object into a work.
    class WorkConversionError < ProcessingConversionError
      self.conversion_target = 'Models::Work'
    end

    # As you are looking up something by name, within a given container.
    class ConceptNotFoundError < RuntimeError
      def initialize(name:, container:)
        super("Unable to find #{name} within #{container}")
      end
    end

    # When you ask for an enrichment but none can be found
    class EnrichmentNotFoundError < ConceptNotFoundError
    end

    # When you just can't find that job, throw an exception.
    class JobNotFoundError < ConceptNotFoundError
    end

    # A policy was not found. Now panic!
    class PolicyNotFoundError < ConceptNotFoundError
    end

    # A Notification was not found.
    class NotificationNotFoundError < ConceptNotFoundError
    end

    # A WorkType was not found.
    class WorkTypeNotFoundError < ConceptNotFoundError
    end

    # A EventTriggerForm was not found.
    class EventTriggerFormNotFoundError < ConceptNotFoundError
    end

    # Unable to find the correct processing strategy role
    class ValidProcessingStrategyRoleNotFoundError < RuntimeError
    end

    # Exposing a custom AuthenticationFailureError
    class AuthenticationFailureError < RuntimeError
      def initialize(context)
        super("Unable to authenticate #{context}")
      end
    end

    # The authentication layer failed to build. Probably need to explain why.
    class FailedToBuildAuthenticationLayerError < RuntimeError
    end

    # The authorization layer failed to build. Probably need to explain why.
    class FailedToBuildAuthorizationLayerError < RuntimeError
    end

    # Exposing a custom AuthorizationFailureError
    class AuthorizationFailureError < RuntimeError
      attr_reader :user, :action_to_authorize, :entity
      def initialize(user:, action_to_authorize:, entity:)
        @user = user
        @action_to_authorize = action_to_authorize
        @entity = entity
        super("#{user.inspect} not allowed to #{action_to_authorize.inspect} this #{entity.inspect}")
      end
    end

    # For some reason, you have an entity in an incorrect state. Push up what
    # information we can to be helpful to the end user.
    class InvalidStateError < RuntimeError
      attr_reader :entity, :actual, :expected
      def initialize(entity:, actual:, expected: nil)
        @entity = entity
        @actual = actual
        @expected = expected
        super(build_message)
      end

      private

      def build_message
        if expected.present?
          "#{self.class}: Expected #{entity} to have state: #{expected}, but it had state: #{actual}"
        else
          "#{self.class}: #{entity} has in valid state: #{actual}"
        end
      end
    end

    # A refinement of InvalidStateError to provide an explicit context
    class InvalidDoiCreationRequestStateError < InvalidStateError
    end

    # Exposing a custom EmailDeliverFailure
    class SenderNotFoundError < ArgumentError
      def initialize(context)
        super("Unable to Send message, To address is required to send a message  #{context}")
      end
    end
  end
end
