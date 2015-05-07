module Sipity
  module Runners
    module SubmissionWindowRunners
      # Responsible for responding with a submission window
      class Show < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :show?

        def run(work_area_slug:, submission_window_slug:)
          submission_window = repository.find_submission_window_by(slug: submission_window_slug, work_area: work_area_slug)
          authorization_layer.enforce!(action_name => submission_window) do
            callback(:success, submission_window)
          end
        end
      end

      # :nodoc:
      class CommandQueryAction < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_area_slug:, submission_window_slug:, processing_action_name:, attributes: {})
          submission_window = repository.find_submission_window_by(slug: submission_window_slug, work_area: work_area_slug)
          form = repository.build_submission_window_processing_action_form(
            submission_window: submission_window, processing_action_name: processing_action_name, attributes: attributes
          )
          authorization_layer.enforce!(processing_action_name => form) do
            yield(form, submission_window)
          end
        end
      end

      # The general handler for general query actions (show may be a customized
      # case).
      class QueryAction < CommandQueryAction
        def run(**keywords)
          super do |form, _submission_window|
            callback(:success, form)
          end
        end
      end

      # The general handler for general query actions (show may be a customized
      # case).
      class CommandAction < CommandQueryAction
        def run(**keywords)
          super do |form, submission_window|
            if form.submit(requested_by: current_user)
              callback(:success, submission_window)
            else
              callback(:failure, form)
            end
          end
        end
      end
    end
  end
end
