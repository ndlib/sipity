require 'sipity/guard_interface_expectation'

module Sipity
  # ResponseHandlers are a means of encapsulating how we respond to an action's
  # response. Action responses should implement the interface of the
  # HandledResponseParameter.
  #
  # This is experimental; After conversations with @terrellt I wanted to
  # eliminate the callbacks of the runners. They were helpful to convey what was
  # happening. I believe the callbacks have reduced some of the complexities
  # of controller testing. There was room for more, and I hope that is made
  # clear through this experimentation.
  #
  # @see Sipity::Parameters::HandledResponseParameter
  # @see Sipity::Runners::BaseRunner
  module ResponseHandlers
    module_function

    def handle_controller_response(context:, handled_response:, container:)
      handle_response(context: context, handled_response: handled_response, container: container, handler: ControllerResponseHandler)
    end

    def handle_command_line_response(context:, handled_response:, container:)
      handle_response(context: context, handled_response: handled_response, container: container, handler: CommandLineResponseHandler)
    end

    # TODO: Remove the template as it can be packed into the handled response
    def handle_response(context:, handled_response:, container:, handler:)
      responder = build_responder(container: container, handled_response_status: handled_response.status)
      handler.respond(context: context, handled_response: handled_response, responder: responder)
    end
    private_class_method :handle_response

    def build_responder(container:, handled_response_status:)
      container.const_get("#{handled_response_status.to_s.classify}Responder")
    end

    # The default response handler for command line applications
    class CommandLineResponseHandler
      def self.respond(**keywords)
        new(**keywords).respond
      end

      attr_reader :handled_response, :responder
      def initialize(handled_response:, responder:, **_keywords)
        self.handled_response = handled_response
        self.responder = responder
      end

      def respond
        responder.for_command_line(handler: self)
      end

      def request_format
        # TODO: Don't know what this should be
      end

      private

      attr_writer :handled_response, :responder
      delegate :object, :status, :errors, to: :handled_response, prefix: :response

      include GuardInterfaceExpectation
      def handled_response=(input)
        guard_interface_expectation!(input, :object, :status, :errors)
        @handled_response = input
      end
    end

    # The default response handler. It makes sure things are well composed,
    # guarding the interface of collaborating objects.
    class ControllerResponseHandler
      def self.respond(**keywords)
        new(**keywords).respond
      end

      attr_reader :context, :handled_response, :responder
      def initialize(context:, handled_response:, responder:)
        self.context = context
        self.handled_response = handled_response
        self.responder = responder
        prepare_context_for_response
      end

      def respond
        responder.for_controller(handler: self)
      end

      delegate :render, :redirect_to, :request_format, to: :context
      delegate :object, :status, :errors, to: :handled_response, prefix: :response
      delegate :template, to: :handled_response

      private

      PATH_METHOD_REGEXP = /_path\Z/

      def method_missing(method_name, *args, **keywords, &block)
        if method_name =~ PATH_METHOD_REGEXP
          context.public_send(method_name, *args, **keywords, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        if method_name =~ PATH_METHOD_REGEXP
          context.respond_to?(method_name, include_private)
        else
          super
        end
      end

      attr_writer :template, :responder

      def prepare_context_for_response
        # Wouldn't it be great if we had proper View objects in Rails? Instead
        # of this crazy copy instance variables from the controller to the
        # template (aka 'ActionView') layer.
        context.view_object = handled_response.object

        # Making sure our context can render all kinds of elements.
        handled_response.with_each_additional_view_path_slug do |slug|
          context.prepend_processing_action_view_path_with(slug: slug)
        end
      end

      include GuardInterfaceExpectation
      def context=(input)
        guard_interface_expectation!(input, :view_object=, :render, :redirect_to, :prepend_processing_action_view_path_with)
        @context = input
      end

      def handled_response=(input)
        guard_interface_expectation!(input, :object, :status, :errors, :template, :with_each_additional_view_path_slug)
        @handled_response = input
      end
    end
  end
end
