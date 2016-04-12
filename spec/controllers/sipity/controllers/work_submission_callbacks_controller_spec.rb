require 'spec_helper'
require 'sipity/controllers/work_submission_callbacks_controller'

module Sipity
  module Controllers
    RSpec.describe WorkSubmissionCallbacksController, type: :controller do
      let(:work) { Models::Work.new(id: 'abc') }
      let(:work_area) { double(slug: 'buggy') }

      before { allow(work).to receive(:work_area).and_return(work_area) }

      context 'configuration' do
        its(:runner_container) { is_expected.to eq(Sipity::Runners::WorkSubmissionsRunners) }
        its(:response_handler_container) { is_expected.to eq(Sipity::ResponseHandlers::WorkSubmissionHandler) }
      end

      it { is_expected.to respond_to :prepend_processing_action_view_path_with }
      it { is_expected.to respond_to :run_and_respond_with_processing_action }

      context '#command_attributes' do

        it 'will normalize parameters' do
          given_params = {
            "host" => "libvirt6.library.nd.edu", "version" => "1.0.0", "job_name" => "sipity-44558c99h70", "job_state" => "success",
            "work_id" => "44558c99h70", "processing_action_name" => "ingest_completed", "work_submission" => {
              "host" => "libvirt6.library.nd.edu", "version" => "1.0.0", "job_name" => "sipity-44558c99h70", "job_state" => "success"
            }
          }
          expect_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action).with(
            work_id: given_params.fetch('work_id'),
            attributes: {
              "host" => "libvirt6.library.nd.edu", "version" => "1.0.0", "job_name" => "sipity-44558c99h70", "job_state" => "success"
            }
          )
          expect do
            post 'command_action', given_params
          end.to raise_error(ActionView::MissingTemplate, /command_action/) # Because auto-rendering
        end
      end

      context '#authenticate_user!' do
        before { allow_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action) }
        let(:processing_action_name) { 'fun_things' }
        context 'with Basic authentication credentials' do
          it 'will attempt to find user_for_etd_ingester' do
            user = double('User')
            expect(controller).to receive(:user_for_etd_ingester).with(user: 'User', password: 'Password').and_return(user)
            request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('User', 'Password')
            controller.authenticate_user!
            expect(controller.instance_variable_get("@current_user")).to eq(user)
          end
        end

        context 'without Basic authentication credentials' do
          it 'will attempt to find user_for_etd_ingester' do
            expect(controller).to_not receive(:user_for_etd_ingester)
            expect { controller.authenticate_user! }.to raise_error(StandardError)
            expect(controller.instance_variable_get("@current_user")).to eq(nil)
          end
        end
      end

      context '#current_user' do
        before { allow_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action) }
        let(:processing_action_name) { 'fun_things' }
        context 'with Basic authentication credentials' do
          it 'will attempt to find user_for_etd_ingester' do
            user = double('User')
            expect(controller).to receive(:user_for_etd_ingester).with(user: 'User', password: 'Password').and_return(user)
            request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('User', 'Password')
            controller.current_user
            expect(controller.instance_variable_get("@current_user")).to eq(user)
          end
        end
      end

      context '#user_for_etd_ingester' do
        let(:valid_name) { Sipity::Models::Group::BATCH_INGESTORS }
        let(:invalid_name) { 'nope' }
        it 'will equal false if its not the ETD Ingester' do
          expect(controller.user_for_etd_ingester(user: invalid_name, password: Figaro.env.sipity_batch_ingester_access_key!)).to eq(false)
        end

        it 'will equal false if that password is incorrect' do
          expect(controller.user_for_etd_ingester(user: valid_name, password: 'nope')).to eq(false)
        end

        it 'will be the ETD Ingester group if the name and password match' do
          group = double('Group')
          expect(Sipity::Models::Group).to receive(:find_by!).with(name: valid_name).and_return(group)
          expect(controller.user_for_etd_ingester(user: valid_name, password: Figaro.env.sipity_batch_ingester_access_key!)).to eq(group)
        end
      end

      context 'POST #command_action' do
        let(:processing_action_name) { 'fun_things' }
        it 'will skip CSRF protections and pass along to the response handler' do
          expect_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action)
          expect(controller).to_not receive(:verify_authenticity_token)
          # I don't want to mess around with all the possible actions
          expect do
            post 'command_action', work_id: work.id, processing_action_name: processing_action_name, work: { title: 'Hello' }
          end.to raise_error(ActionView::MissingTemplate, /command_action/) # Because auto-rendering
        end
      end

      context 'GET #query_action' do
        let(:processing_action_name) { 'fun_things' }
        it 'will not be routable' do
          expect do
            get 'query_action', work_id: work.id, processing_action_name: processing_action_name, work: { title: 'Hello' }
          end.to raise_error(ActionController::UrlGenerationError)
        end
      end
    end
  end
end
