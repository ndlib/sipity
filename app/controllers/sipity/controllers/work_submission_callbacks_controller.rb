module Sipity
  module Controllers
    # The controller for handling callbacks for work submissions
    class WorkSubmissionCallbacksController < ApplicationController
      skip_before_action :verify_authenticity_token

      class_attribute :response_handler_container
      self.runner_container = Sipity::Runners::WorkSubmissionsRunners
      self.response_handler_container = Sipity::ResponseHandlers::WorkSubmissionHandler

      def command_action
        run_and_respond_with_processing_action(work_id: work_id, attributes: command_attributes)
      end

      def initialize(*args, &block)
        super(*args, &block)
        self.processing_action_composer = ProcessingActionComposer.build_for_controller(controller: self)
      end

      delegate(
        :prepend_processing_action_view_path_with,
        :run_and_respond_with_processing_action,
        to: :processing_action_composer
      )

      attr_accessor :view_object
      helper_method :view_object
      alias model view_object
      helper_method :model

      # @todo With Cogitate this will need to be revisited
      def authenticate_user!
        authenticated_user = authenticate_with_http_basic { |user, password| user_for_etd_ingester(user: user, password: password) }
        if authenticated_user
          @current_user = authenticated_user
        else
          super
        end
      end

      # Required because the authorization layer is firing the current user test prior to the authenticate_user! action filter
      # The end result was that the user for the web request came through as nil in the authorization layer.
      #
      # @todo With Cogitate this will need to be revisited
      def current_user
        return @current_user if @current_user
        authenticate_user!
        @current_user
      end

      # @todo With Cogitate this will need to be revisited
      def user_for_etd_ingester(user:, password:, group_name: Models::Group::BATCH_INGESTORS, env: Figaro.env)
        return false unless user == group_name
        return false unless password == env.sipity_batch_ingester_access_key!
        Sipity::Models::Group.find_by!(name: group_name)
      end

      private

      attr_accessor :processing_action_composer

      def work_id
        params.require(:work_id)
      end

      # This is a bit different as I am matching to the WEBHOOK documentation. The WEBHOOK posts the following JSON body:
      #
      # ```json
      #   { "host" : "libvirt8.library.nd.edu", "version" : "1.0.1", "job_name" : "ingest-45", "job_state" : "processing" }
      # ```
      #
      # So I need to normalize this data to pass along to the command.
      #
      # @see https://github.com/ndlib/curatend-batch/blob/master/webhook.md
      def command_attributes
        params.fetch(:work) { HashWithIndifferentAccess.new }.merge(normalized_attributes_for_existing_callback_constraints)
      end

      def normalized_attributes_for_existing_callback_constraints
        params.except(:action, :controller, :work_id, :processing_action_name, :work, :work_submission)
      end
    end
  end
end
