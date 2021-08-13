require "rails_helper"
require 'sipity/controllers/work_areas/etd/show_presenter'

module Sipity
  module Controllers
    module WorkAreas
      module Etd
        RSpec.describe ShowPresenter do
          let(:context) { PresenterHelper::ContextWithForm.new(current_user: current_user, request: double(path: '/path'), paginate: true) }
          let(:current_user) { double('Current User') }
          let(:work_area) { double(slug: 'the-slug', title: 'The Slug', processing_state: 'new', order: 'title', page: 1) }
          let(:repository) { QueryRepositoryInterface.new }
          let(:translator) { double(call: true) }
          subject { described_class.new(context, work_area: work_area, repository: repository, translator: translator) }

          let(:submission_window) { double }
          let(:processing_action) { double(name: 'start_a_submission') }

          before do
            allow(repository).to receive(:find_submission_window_by).and_return(submission_window)
            allow_any_instance_of(described_class).to receive(:convert_to_processing_action).and_return(processing_action)
          end
          it { is_expected.to be_a(Sipity::Controllers::WorkAreas::Core::ShowPresenter) }
          its(:view_submitted_etds_url) { is_expected.to match(%r{\Ahttps://curate.nd.edu}) }
          its(:reset_path) { is_expected.to match('/areas/etd') }

          its(:additional_attributes) { is_expected.to eq(["author_name", "etd_submission_date", "program_name"]) }
        end
      end
    end
  end
end
