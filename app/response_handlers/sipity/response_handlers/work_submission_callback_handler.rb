require 'power_converter'

module Sipity
  module ResponseHandlers
    # These handlers are very nosy; In object perlance they are doing little on
    # their own, but instead coordinating that reality.
    #
    # @todo should this module be moved into the Runner's namespace? It would give a closer proximity to the code that was being leveraged.
    module WorkSubmissionCallbackHandler
      # It worked
      module SuccessResponder
        def self.for_controller(handler:)
          handler.render(template: handler.template)
        end

        # @review should I consider if a logger is passed?
        def self.for_command_line(*)
          return true
        end
      end

      # It worked
      module RedirectResponder
        def self.for_controller(handler:)
          handler.redirect_to(handler.response_object.url)
        end

        # @review should I consider if a logger is passed?
        def self.for_command_line(handler:)
          raise(
            Sipity::Exceptions::ResponseHandlerError,
            object: handler.response_object,
            errors: [],
            status: handler.response_status
          )
        end
      end

      # We have a successful form submission.
      module SubmitSuccessResponder
        def self.for_controller(handler:)
          handler.render(template: handler.template, status: :ok)
        end

        # @review should I consider if a logger is passed?
        def self.for_command_line(*)
          return true
        end
      end

      # Forms that raise to submit may have different errors.
      module SubmitFailureResponder
        def self.for_controller(handler:)
          handler.render(template: handler.template, status: :unprocessable_entity)
        end

        # @review should I consider if a logger is passed?
        def self.for_command_line(handler:)
          raise(
            Sipity::Exceptions::ResponseHandlerError,
            object: handler.response_object,
            errors: handler.response_errors,
            status: handler.response_status
          )
        end
      end
    end
  end
end
