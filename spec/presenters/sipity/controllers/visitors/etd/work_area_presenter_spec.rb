require "rails_helper"
require 'sipity/controllers/visitors/etd/work_area_presenter'

module Sipity
  module Controllers
    module Visitors
      module Etd
        RSpec.describe WorkAreaPresenter do
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

          its(:view_submitted_etds_url) { is_expected.to match(%r{\Ahttps://curate.nd.edu}) }
          its(:login_path) { is_expected.to start_with('/sign_in') }
        end
      end
    end
  end
end
