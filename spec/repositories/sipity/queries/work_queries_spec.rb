require 'rails_helper'
require 'sipity/queries/work_queries'

module Sipity
  module Queries
    RSpec.describe WorkQueries, type: :isolated_repository_module do
      describe '#find_works_via_search' do
        let(:repository) { QueryRepository.new }
        let(:criteria) { Parameters::SearchCriteriaForWorksParameter.new }
        subject { test_repository.find_works_via_search(criteria: criteria, repository: repository) }
        it { is_expected.to be_a(ActiveRecord::Relation) }

        describe 'when passed a work area as part of the criteria' do
          let(:work_area) { Models::WorkArea.new(name: 'etd') }
          let(:criteria) { Parameters::SearchCriteriaForWorksParameter.new(work_area: work_area) }
          before do
            expect(test_repository).to receive(:apply_work_area_filter_to).and_call_original
          end
          it { is_expected.to be_a(ActiveRecord::Relation) }
        end

        describe 'when requested page is outside the total pages range' do
          let(:criteria) { Parameters::SearchCriteriaForWorksParameter.new(page: 3) }
          it 'will raise an ActiveRecord::RecordNotFound error when requested page is outside the total pages range' do
            expect { subject }.to raise_error(Exceptions::RequestOutsidePaginationRange)
          end
        end
      end

      context '#find_work_by' do
        it 'raises an exception if nothing is found' do
          expect { test_repository.find_work_by(id: '8675309') }.to raise_error(ActiveRecord::RecordNotFound)
        end
        it 'returns the Work when the object is found' do
          work = Models::Work.create!(id: '8675309', title: "Hello")
          expect(test_repository.find_work_by(id: '8675309')).to eq(work)
        end
      end

      context '#build_work_submission_processing_action_form' do
        let(:parameters) { { work: double, processing_action_name: double, attributes: double } }
        let(:form) { double }
        it 'will delegate the heavy lifting to a builder' do
          expect(Forms::WorkSubmissions).to receive(:build_the_form).with(repository: test_repository, **parameters).and_return(form)
          expect(test_repository.build_work_submission_processing_action_form(parameters)).to eq(form)
        end
      end

      context '#work_access_right_code' do
        let(:work) { Models::Work.new(title: 'Hello World', id: '123') }
        it 'will expose access_right_code of the underlying work' do
          Models::AccessRight.create!(entity: work, access_right_code: 'private_access')
          expect(test_repository.work_access_right_code(work: work)).to eq('private_access')
        end
      end

      context '#build_dashboard_view' do
        let(:user) { double }
        let(:filter) { double }
        subject { test_repository.build_dashboard_view(user: user, filter: filter, page: 1) }
        it { is_expected.to respond_to :filterable_processing_states }
        it { is_expected.to respond_to :search_path }
      end
    end
  end
end
