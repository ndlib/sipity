require "rails_helper"
require 'sipity/controllers/visitors_controller'

module Sipity
  module Controllers
    RSpec.describe VisitorsController, type: :controller do
      let(:work_area) { Models::WorkArea.new(slug: 'work-area') }
      let(:status) { :success }
      # REVIEW: It is possible the runner will return a well formed object
      let(:runner) { double('Runner', run: [status, work_area]) }

      it { is_expected.to_not be_a(Sipity::Controllers::AuthenticatedController) }

      context 'configuration' do
        its(:runner_container) { is_expected.to eq(Sipity::Runners::VisitorsRunner) }
        its(:response_handler_container) { is_expected.to eq(Sipity::ResponseHandlers::WorkAreaHandler) }
      end

      context 'GET #work_area' do
        it 'will will collaborate with the processing action composer' do
          expect_any_instance_of(ProcessingActionComposer).to receive(:run_and_respond_with_processing_action)
          expect do
            get('work_area', params: { work_area_slug: work_area.slug })
          end.to raise_error(ActionView::MissingTemplate, /work_area/) # Because auto-rendering
        end
      end
    end
  end
end
