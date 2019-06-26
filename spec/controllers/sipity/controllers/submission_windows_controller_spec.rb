require "rails_helper"
require 'sipity/controllers/submission_windows_controller'

module Sipity
  module Controllers
    RSpec.describe SubmissionWindowsController, type: :controller do
      let(:submission_window) { Models::SubmissionWindow.new(slug: 'start', work_area: work_area) }
      let(:work_area) { Models::WorkArea.new(slug: 'etd') }
      context 'configuration' do
        its(:runner_container) { is_expected.to eq(Runners::SubmissionWindowRunners) }
        its(:response_handler_container) { is_expected.to eq(ResponseHandlers::SubmissionWindowHandler) }
      end
      it { is_expected.to be_a(Sipity::Controllers::AuthenticatedController) }

      context 'GET #query_action' do
        let(:processing_action_name) { 'fun_things' }
        it 'will pass along to processing action composer' do
          expect_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action)
          expect do
            get(
              'query_action',
              params: {
                work_area_slug: work_area.slug,
                submission_window_slug: submission_window.slug,
                processing_action_name: processing_action_name,
                submission_window: { title: 'Hello' }
              }
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
            params: {
              work_area_slug: work_area.slug,
              submission_window_slug: submission_window.slug,
              processing_action_name: processing_action_name,
              submission_window: { title: 'Hello' }
            }
          )
          expect(response.status).to eq(204)
        end
      end
    end
  end
end
