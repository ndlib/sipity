require "rails_helper"
require 'sipity/controllers/work_submission_callbacks_controller'

module Sipity
  module Controllers
    RSpec.describe WorkSubmissionCallbacksController, type: :controller do
      let(:work) { Models::Work.new(id: 'abc') }
      let(:work_area) { double(slug: 'buggy') }

      before { allow(work).to receive(:work_area).and_return(work_area) }

      context 'configuration' do
        its(:runner_container) { is_expected.to eq(Sipity::Runners::WorkSubmissionsRunners) }
        its(:response_handler_container) { is_expected.to eq(Sipity::ResponseHandlers::WorkSubmissionCallbackHandler) }
      end

      it { is_expected.to be_a(Sipity::Controllers::AuthenticatedController) }

      it { is_expected.to respond_to :prepend_processing_action_view_path_with }
      it { is_expected.to respond_to :run_and_respond_with_processing_action }

      context '#command_attributes' do

        it 'will normalize QUERY parameters' do
          given_params = {
            "host" => "libvirt6.library.nd.edu", "version" => "1.0.0", "job_name" => "sipity-44558c99h70", "job_state" => "success",
            "work_id" => "44558c99h70", "processing_action_name" => "ingest_completed", "work_submission" => {}
          }

          expected_parameters = ActionController::Parameters.new(
            work_id: given_params.fetch('work_id'),
            attributes: {
              "host" => "libvirt6.library.nd.edu", "version" => "1.0.0", "job_name" => "sipity-44558c99h70", "job_state" => "success"
            }
          )
          expect_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action).with(expected_parameters)
          expect do
            post 'command_action', params: given_params
          end.to raise_error(ActionView::MissingTemplate, /command_action/) # Because auto-rendering
        end

        it 'will normalize posted body parameters' do
          json_body = '{"host":"curatewkrprod.library.nd.edu", "version":"1.1.4", "job_name":"sipity-44558c99h70", "job_state":"success"}'
          expected_parameters = ActionController::Parameters.new(work_id: work.to_param, attributes: JSON.parse(json_body))

          expect_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action).with(expected_parameters)

          expect do
            request.env['RAW_POST_DATA'] = json_body
            post 'command_action', params: { work_id: work.to_param, processing_action_name: 'ingest_completed', format: :json }
          end.to raise_error(ActionView::MissingTemplate, /command_action/) # Because auto-rendering
        end
      end

      context 'POST #command_action' do
        let(:processing_action_name) { 'fun_things' }
        it 'will skip CSRF protections and pass along to the response handler' do
          expect_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action)
          expect(controller).to_not receive(:verify_authenticity_token)
          # I don't want to mess around with all the possible actions
          expect do
            post 'command_action', params: { work_id: work.id, processing_action_name: processing_action_name, work: { title: 'Hello' } }
          end.to raise_error(ActionView::MissingTemplate, /command_action/) # Because auto-rendering
        end
      end

      context 'GET #query_action' do
        let(:processing_action_name) { 'fun_things' }
        it 'will not be routable' do
          expect do
            get 'query_action', params: { work_id: work.id, processing_action_name: processing_action_name, work: { title: 'Hello' } }
          end.to raise_error(ActionController::UrlGenerationError)
        end
      end
    end
  end
end
