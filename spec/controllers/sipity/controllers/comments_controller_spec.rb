require "rails_helper"
require 'sipity/controllers/comments_controller'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe CommentsController, type: :controller do
      it { is_expected.to be_a(Sipity::Controllers::AuthenticatedController) }

      let(:work) { Models::Work.new(title: 'The Title', id: '1234') }
      context 'GET #index' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: { work_id: work.to_param }, context: controller
          )
        end

        let(:yields) { work }
        let(:callback_name) { :success }
        it 'will render the index page' do
          get 'index', params: { work_id: work.to_param }
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('index')
        end
      end
    end
  end
end
