require 'sipity/runners/base_runner'
require 'active_record/base'

module Sipity
  module Runners
    # Container for WorkSubmission's "action" runners
    module WorkSubmissionsRunners
      # :nodoc:
      class CommandQueryAction < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_id:, processing_action_name:, attributes: {})
          enforce_authentication!
          work = repository.find_work_by(id: work_id)
          form = repository.build_work_submission_processing_action_form(
            work: work, processing_action_name: processing_action_name, attributes: attributes, requested_by: current_user
          )
          authorization_layer.enforce!(processing_action_name => form) do
            yield(form, work)
          end
        end
      end
      private_constant :CommandQueryAction

      # The general handler for general query actions (show may be a customized
      # case).
      class QueryAction < CommandQueryAction
        def run(work_id:, processing_action_name:, attributes: {})
          super do |form, _work|
            callback(:success, form)
          end
        end
      end

      # The general handler for all command actions
      class CommandAction < CommandQueryAction
        def run(work_id:, processing_action_name:, attributes: {})
          super do |form, _work|
            ActiveRecord::Base.transaction do
              response = form.submit
              if response
                callback(:submit_success, response)
              else
                callback(:submit_failure, form)
              end
            end
          end
        end
      end
    end
  end
end
