require "rails_helper"
require 'sipity/controllers/work_areas_controller'

module Sipity
  module Controllers
    RSpec.describe WorkAreasController, type: :controller do
      let(:work_area) { Models::WorkArea.new(slug: 'work-area') }
      let(:status) { :success }
      # REVIEW: It is possible the runner will return a well formed object
      let(:runner) { double('Runner', run: [status, work_area]) }
      context 'configuration' do
        its(:runner_container) { is_expected.to eq(Sipity::Runners::WorkAreaRunners) }
        its(:response_handler_container) { is_expected.to eq(Sipity::ResponseHandlers::WorkAreaHandler) }
      end

      it { is_expected.to be_a(Sipity::Controllers::AuthenticatedController) }

      context '#query_or_command_attributes' do
        it 'will merge the :page attribute if the work area does not already have one' do
          allow(controller).to receive(:params).and_return(work_area: { chicken: 'nugget' }, page: 1)
          expect(controller.send(:query_or_command_attributes)).to eq(chicken: 'nugget', page: 1)
        end

        it 'will not add the :page attribute if the work area has one' do
          allow(controller).to receive(:params).and_return(work_area: { chicken: 'nugget', page: 'hello' }, page: 1)
          expect(controller.send(:query_or_command_attributes)).to eq(chicken: 'nugget', page: 'hello')
        end

        it 'will not append :page attribute if none is present' do
          allow(controller).to receive(:params).and_return(work_area: { chicken: 'nugget' })
          expect(controller.send(:query_or_command_attributes)).to eq(chicken: 'nugget')
        end
      end

      context 'GET #query_action' do
        let(:processing_action_name) { 'fun_things' }
        it 'will will collaborate with the processing action composer' do
          expect_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action)
          expect do
            get(
              'query_action',
              params: {
                work_area_slug: work_area.slug,
                processing_action_name: processing_action_name,
                work_area: { title: 'Hello' }
              }
            )
          end.to raise_error(ActionController::UnknownFormat) # Because of default rendering
        end
      end

      context 'POST #command_action' do
        let(:processing_action_name) { 'fun_things' }
        it 'will will collaborate with the processing action composer' do
          expect_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action)

          # I don't want to mess around with all the possible actions
          post(
            'command_action',
            params: { work_area_slug: work_area.slug,
              processing_action_name: processing_action_name,
              work_area: { title: 'Hello' }
            }
          )
        end
      end
    end
  end
end
