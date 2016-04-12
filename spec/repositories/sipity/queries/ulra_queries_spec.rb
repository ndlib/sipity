require 'spec_helper'
require 'sipity/queries/ulra_queries'

RSpec.describe Sipity::Queries::UlraQueries, type: :isolated_repository_module do
  let(:work) { Sipity::Models::Work.new(id: 1) }
  let(:another_work) { Sipity::Models::Work.new(id: 2) }
  context '#possible_expected_graduation_terms' do
    it 'will return an array of semesters' do
      expect(test_repository.possible_expected_graduation_terms(ending_year: 2015, work: work)).to eq(
        [
          "Spring 2014", "Summer 2014", "Fall 2014",
          "Spring 2015", "Summer 2015", "Fall 2015",
          "Spring 2016", "Summer 2016", "Fall 2016",
          "Spring 2017", "Summer 2017", "Fall 2017",
          "Spring 2018", "Summer 2018", "Fall 2018"
        ]
      )
    end
  end

  context '#collection_pid_for' do
    let(:submission_window) { Sipity::Models::SubmissionWindow.new(slug: submission_window_slug, work_area: work_area) }
    let(:work_area) { Sipity::Models::WorkArea.new(slug: work_area_slug) }
    let(:key) { 'participant' }
    context 'ETD work area' do
      let(:work_area_slug) { 'etd' }
      let(:submission_window_slug) { '2016' }
      it "should raise an error" do
        expect { test_repository.collection_pid_for(submission_window: submission_window, key: key) }.to raise_error(KeyError)
      end
    end

    context 'ULRA work area' do
      let(:work_area_slug) { 'ulra' }
      context 'for 2016 submission window' do
        let(:submission_window_slug) { '2016' }

        context 'with invalid key' do
          let(:key) { 'another' }
          it "should raise an error" do
            expect { test_repository.collection_pid_for(submission_window: submission_window, key: key) }.to raise_error(KeyError)
          end
        end

        context 'with valid key' do
          let(:key) { 'participant' }
          subject { test_repository.collection_pid_for(submission_window: submission_window, key: key) }
          it { is_expected.to be_a(String) }
        end
      end
    end
  end
end
