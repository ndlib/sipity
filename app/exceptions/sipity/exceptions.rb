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

    # When something about the entity for a given policy is just not quite
    # right.
    class PolicyEntityExpectationError < RuntimeError
    end

    # When passing parameters through the job layer, passing complex objects
    # can cause problems; In that we don't want to pass state across the async
    # boundary.
    class NonPrimativeParameterError < RuntimeError
    end

    # This is not a defined resourceful action
    class UnprocessableResourcefulActionNameError < RuntimeError
      def initialize(name)
        super("Received unexpected action name (#{name})")
      end
    end

    # There was a problem referencing the state for a policy lookup.
    class StatePolicyQuestionRoleMapError < RuntimeError
      def initialize(state:, context:)
        super("Could not find #{state} in the corresponding map for #{context}")
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

    # Unable to convert the given object into a processing entity
    class ProcessingEntityConversionError < ConversionError
      self.conversion_target = 'Models::Processing::Entity'
    end

    # Unable to convert the given object into a processing actor
    class ProcessingActorConversionError < ConversionError
      self.conversion_target = 'Models::Processing::Actor'
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

    # A StateMachine was not found.
    class StateMachineNotFoundError < ConceptNotFoundError
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
        @user, @action_to_authorize, @entity = user, action_to_authorize, entity
        super("#{user} not allowed to #{action_to_authorize} this #{entity}")
      end
    end

    # The proposed state diagram was malformed.
    class InvalidStateDiagramRawStructure < RuntimeError
      attr_reader :structure
      def initialize(structure:)
        @structure = structure
        super("#{structure} is not well formed for StateDiagram")
      end
    end

    # For some reason, you have an entity in an incorrect state. Push up what
    # information we can to be helpful to the end user.
    class InvalidStateError < RuntimeError
      attr_reader :entity, :actual, :expected
      def initialize(entity:, actual:, expected: nil)
        @entity, @actual, @expected = entity, actual, expected
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
  end
end
