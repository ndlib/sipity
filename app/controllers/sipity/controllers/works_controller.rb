module Sipity
  module Controllers
    # The controller for creating works.
    class WorksController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::WorkRunners

      def new
        _status, model = run(attributes: new_params)
        @model = Decorators::WorkDecorator.decorate(model)
        respond_with(@model)
      end

      def create
        status, model = run(attributes: create_params)
        @model = Decorators::WorkDecorator.decorate(model)
        flash[:notice] = message_for(status, title: @model.title)
        respond_with(@model)
      end

      def show
        _status, model = run(work_id: work_id)
        @model = Decorators::WorkDecorator.decorate(model)
        respond_with(@model)
      end

      def edit
        _status, @model = run(work_id: work_id)
        @model = Decorators::WorkDecorator.decorate(model)
        respond_with(@model)
      end

      def update
        status, @model = run(work_id: work_id, attributes: update_params)
        flash[:notice] = message_for(status, title: @model.title)
        respond_with(@model)
      end

      # TODO: Allow works to be destroyed
      def destroy
        flash[:warn] = 'You cannot delete this work.'
        redirect_to(action: 'show')
      end

      attr_reader :model
      protected :model
      helper_method :model

      private

      def work_id
        params.require(:id)
      end

      def new_params
        params[:work] || {}
      end

      def create_params
        params.require(:work)
      end

      def update_params
        params.require(:work)
      end
    end
  end
end
