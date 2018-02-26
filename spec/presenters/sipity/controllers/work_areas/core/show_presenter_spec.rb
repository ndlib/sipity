require "rails_helper"
require 'sipity/controllers/work_areas/core/show_presenter'

module Sipity
  module Controllers
    module WorkAreas
      module Core
        RSpec.describe ShowPresenter do
          let(:context) { PresenterHelper::ContextWithForm.new(current_user: current_user, request: double(path: '/path'), paginate: true) }
          let(:current_user) { double('Current User') }
          let(:work_area) do
            double(slug: 'the-slug', submission_window: '2016', title: 'The Slug', processing_state: 'new', order: 'title', page: 1, q: nil)
          end
          let(:repository) { QueryRepositoryInterface.new }
          let(:processing_action) { double(name: 'start_a_submission') }
          subject { described_class.new(context, work_area: work_area, repository: repository) }

          before do
            allow_any_instance_of(described_class).to receive(:convert_to_processing_action).and_return(processing_action)
          end

          context '#filter_form' do
            it 'will render a form' do
              expect(context).to receive(:form_tag).and_yield
              expect { |b| subject.filter_form(&b) }.to yield_control
            end
          end

          context '#works' do
            it 'will be an enumerable' do
              expect(repository).to receive(:find_works_via_search).with(criteria: kind_of(Parameters::SearchCriteriaForWorksParameter)).
                and_call_original
              subject.works
            end
          end

          context '#paginate_works' do
            it 'will paginate existing works' do
              works = double
              allow(repository).to receive(:find_works_via_search).and_return(works)
              expect(context).to receive(:paginate).with(works)
              subject.paginate_works
            end
          end

          context '#search_criteria' do
            subject do
              described_class.new(context, work_area: work_area, repository: repository).send(:search_criteria)
            end
            its(:work_area) { is_expected.to eq(work_area) }
          end
        end
      end
    end
  end
end
