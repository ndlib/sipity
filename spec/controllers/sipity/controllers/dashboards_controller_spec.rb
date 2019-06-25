require "rails_helper"
require 'sipity/controllers/dashboards_controller'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe DashboardsController, type: :controller do
      context 'GET #index' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: view_object, callback_name: callback_name, run_with: { processing_state: 'hello', page: nil }, context: controller
          )
        end
        let(:view_object) { double }
        let(:callback_name) { :success }
        it { is_expected.to be_a(Sipity::Controllers::AuthenticatedController) }
        it 'will render the new page' do
          get 'index', params: { processing_state: 'hello' }
          expect(assigns(:view)).to_not be_nil
          expect(response).to render_template('index')
        end
      end
    end
  end
end
