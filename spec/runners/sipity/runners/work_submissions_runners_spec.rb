require "rails_helper"
require 'sipity/runners/work_submissions_runners'
require 'sipity/runners/work_submissions_runners'

module Sipity
  module Runners
    module WorkSubmissionsRunners
      include RunnersSupport

      RSpec.describe QueryAction do
        let(:work) { double('Work', id: 1) }
        let(:user) { double('User') }
        let(:form) { double('Form') }
        let(:processing_action_name) { 'fun_things' }
        let(:context) do
          TestRunnerContext.new(
            find_work_by: work, current_user: user, build_work_submission_processing_action_form: form
          )
        end
        let(:handler) { double(invoked: true) }

        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        it 'issues the :success callback' do
          expect(subject).to receive(:enforce_authentication!).and_call_original
          response = subject.run(work_id: work.id, processing_action_name: processing_action_name, attributes: double)
          expect(handler).to have_received(:invoked).with("SUCCESS", form)
          expect(response).to eq([:success, form])
        end
      end

      RSpec.describe CommandAction do
        let(:work) { double('Work', id: 1) }
        let(:user) { double('User') }
        let(:form) { double('Form') }
        let(:processing_action_name) { 'fun_things' }
        let(:context) do
          TestRunnerContext.new(
            find_work_by: work, current_user: user, build_work_submission_processing_action_form: form
          )
        end
        let(:handler) { double(invoked: true) }

        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.submit_success { |a| handler.invoked("SUCCESS", a) }
            on.submit_failure { |a| handler.invoked("FAILURE", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        it 'issues the :submit_success callback when form is submitted' do
          thing = double
          expect(form).to receive(:submit).and_return(thing)
          expect(subject).to receive(:enforce_authentication!).and_call_original
          response = subject.run(work_id: work.id, processing_action_name: processing_action_name, attributes: double)
          expect(handler).to have_received(:invoked).with("SUCCESS", thing)
          expect(response).to eq([:submit_success, thing])
        end

        it 'issues the :submit_failure callback when form fails to submit' do
          expect(form).to receive(:submit).and_return(false)
          expect(subject).to receive(:enforce_authentication!).and_call_original
          response = subject.run(work_id: work.id, processing_action_name: processing_action_name, attributes: double)
          expect(handler).to have_received(:invoked).with("FAILURE", form)
          expect(response).to eq([:submit_failure, form])
        end
      end
    end
  end
end
