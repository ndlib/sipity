module Sipity
  module Jobs
    module Etd
      # Responsible for performing an action on a work. In many ways this
      # mimics how the Controller interacts with the runner layer. As such it also makes concessions on how the controller works.
      #
      # @note This is also a class that jumps through torturous steps so that I don't have to alter the Controller behavior. To consider
      #   is how I can better share the ProcessingActionComposer so that I'm not jumping through layers of builder/lambda hell.
      #
      # @see Sipity::Controllers::WorkSubmissionsController
      class PerformActionForWorkJob
        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(work_id:, processing_action_name:, requested_by:, **keywords)
          self.work_id = work_id
          self.requested_by = requested_by
          self.processing_action_name = processing_action_name
          assign_attributes_from(keywords: keywords)
          set_context!
          set_processing_action_handler!
        end

        def call
          processing_action_handler.run_and_respond_with_processing_action(work_id: work_id, attributes: attributes)
        end

        private

        def assign_attributes_from(keywords:)
          self.attributes = keywords.fetch(:attributes)
          [:context_builder, :runner, :processing_action_handler_builder].each do |attribute_name|
            send("#{attribute_name}=", keywords.fetch(attribute_name) { send("default_#{attribute_name}") })
          end
        end

        attr_accessor :work_id, :requested_by, :processing_action_name

        attr_reader :context

        def set_context!
          @context = context_builder.call(requested_by: requested_by)
        end

        attr_reader :processing_action_handler

        def set_processing_action_handler!
          @processing_action_handler = processing_action_handler_builder.call(
            context: context,
            processing_action_name: processing_action_name,
            runner: runner,
            response_handler_container: Sipity::ResponseHandlers::WorkSubmissionHandler
          )
        end

        attr_accessor :attributes

        attr_accessor :processing_action_handler_builder

        def default_processing_action_handler_builder
          require 'sipity/controllers/processing_action_composer.rb' unless defined?(Sipity::Controllers::ProcessingActionComposer)
          Sipity::Controllers::ProcessingActionComposer.method(:build_for_command_line)
        end

        attr_accessor :context_builder

        def default_context_builder
          require 'sipity/command_line_context' unless defined?(Sipity::CommandLineContext)
          Sipity::CommandLineContext.method(:new)
        end

        attr_accessor :runner

        def default_runner
          # Why does this look so weird? Because Rails Controllers are crazy creatures.
          # And I'm attempting to map to the Rails controller behavior. There is a refactor that could happen to better align the
          # controller code. But I need to get this working before I revisit the other.
          require 'sipity/runners/work_submissions_runners' unless defined?(Sipity::Runners::WorkSubmissionsRunners::CommandAction)
          -> (*args) { Sipity::Runners::WorkSubmissionsRunners::CommandAction.run(context, *args) }
        end
      end
    end
  end
end
