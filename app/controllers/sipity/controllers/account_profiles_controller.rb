module Sipity
  module Controllers
    # Controller responsible for rendering a user's dashboard. That is to say
    # How can I see everything?
    class AccountProfilesController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::AccountProfileRunners

      def edit
        _status, @model = run(attributes: edit_params)
        respond_with(@model)
      end

      def update
        run(attributes: update_params) do |on|
          on.success do |user|
            redirect_destination = session['user_return_to'] || dashboard_path
            redirect_to redirect_destination, notice: message_for("update_account_profile", title: user)
          end
          on.failure do |model|
            @model = model
            render action: 'edit'
          end
        end
      end

      # Because I am leveraging Warden and Devise to negotiate the difference
      # between a user that has agreed to terms of service and one that has
      # not.
      #
      # @see config/initializers/devise.rb
      def current_user
        current_user_for_profile_management
      end
      helper_method :current_user

      attr_reader :model
      protected :model
      helper_method :model

      private

      def edit_params
        params[:account] || {}
      end

      def update_params
        params.require(:account)
      end
    end
  end
end
