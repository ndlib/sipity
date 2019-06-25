require "rails_helper"
require 'sipity/controllers/work_submissions_controller'

module Sipity
  module Controllers
    RSpec.describe WorkSubmissionsController, type: :controller do
      let(:work) { Models::Work.new(id: 'abc') }
      let(:work_area) { double(slug: 'buggy') }

      before { allow(work).to receive(:work_area).and_return(work_area) }

      it { is_expected.to be_a(Sipity::Controllers::AuthenticatedController) }

      context 'configuration' do
        its(:runner_container) { is_expected.to eq(Sipity::Runners::WorkSubmissionsRunners) }
        its(:response_handler_container) { is_expected.to eq(Sipity::ResponseHandlers::WorkSubmissionHandler) }
      end

      it { is_expected.to respond_to :prepend_processing_action_view_path_with }
      it { is_expected.to respond_to :run_and_respond_with_processing_action }

      context 'GET #query_action' do
        let(:processing_action_name) { 'fun_things' }
        it 'will will collaborate with the processing action composer' do
          expect_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action)

          expect do
            get(
              'query_action',
              params: { work_id: work.id, processing_action_name: processing_action_name, work: { title: 'Hello' } }
            )
          end.to raise_error(ActionController::UnknownFormat) # Because auto-rendering
        end
      end

      context 'POST #command_action' do
        let(:processing_action_name) { 'fun_things' }
        it 'will pass along to the response handler' do
          expect_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action)

          post(
            'command_action',
            params: { work_id: work.id, processing_action_name: processing_action_name, work: { title: 'Hello' } }
          )
        end
      end
    end
  end
end
