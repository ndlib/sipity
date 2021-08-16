require "rails_helper"
require 'sipity/parameters/search_criteria_for_works_parameter'

module Sipity
  module Parameters
    RSpec.describe SearchCriteriaForWorksParameter do

      context 'configuration' do
        subject { described_class }
        its(:default_order) { is_expected.to be_a(String) }
        its(:order_options_for_select) { is_expected.to be_a(Array) }
      end

      context 'instance' do
        subject { described_class.new }
        it { is_expected.to respond_to(:user) }
        it { is_expected.to respond_to(:processing_state) }
        it { is_expected.to respond_to(:order) }
        it { is_expected.to respond_to(:proxy_for_type) }
        it { is_expected.to respond_to(:work_area) }
        it { is_expected.to respond_to(:page) }
        it { is_expected.to respond_to(:per) }
        it { is_expected.to respond_to(:submission_window) }
      end

      its(:default_page) { is_expected.to eq(1) }
      its(:page?) { is_expected.to eq(true) }
      its(:default_per) { is_expected.to eq(15) }
      its(:per?) { is_expected.to eq(true) }
      its(:default_user) { is_expected.to eq(nil) }
      its(:user?) { is_expected.to eq(false) }
      its(:default_proxy_for_type) { is_expected.to eq(Models::Work) }
      its(:proxy_for_type?) { is_expected.to eq(true) }
      its(:default_processing_state) { is_expected.to eq(nil) }
      its(:processing_state?) { is_expected.to eq(false) }
      its(:work_area?) { is_expected.to eq(false) }
      its(:default_submission_window) { is_expected.to eq(nil) }
      its(:submission_window?) { is_expected.to eq(false) }
      its(:default_order) { is_expected.to eq('title'.freeze) }
      its(:order?) { is_expected.to eq(true) }
      its(:default_q) { is_expected.to eq(nil) }
      its(:q?) { is_expected.to eq(false) }
      its(:processing_states) { is_expected.to be_a(Array) }

      describe '#q' do
        it 'can be set' do
          subject = described_class.new(q: 'Hello')
          expect(subject.q?).to eq(true)
          expect(subject.q).to eq('Hello')
        end
      end

      describe '#processing_states' do
        it 'can be set' do
          subject = described_class.new(processing_state: 'Hello')
          expect(subject.processing_states).to eq(["Hello"])
          expect(subject.processing_states?).to eq(true)
        end
      end

      describe '#page' do
        it 'coerces to an integer' do
          subject = described_class.new(page: '1')
          expect(subject.page?).to eq(true)
          expect(subject.page).to eq(1)
        end
      end

      it 'will fallback on default order if an invalid order is given' do
        subject = described_class.new(order: 'chicken-sandwich')
        expect(subject.order).to eq(subject.send(:default_order))
      end

      describe '#apply_and_return' do
        it 'limits one record per work even on additional attributes which has many' do
          work = Models::Work.create!(id: "abcd", title: "Working for the man")
          (1..3).each do |index|
            work.additional_attributes.create!(key: "program_name", value: "Program Name #{index}")
            work.additional_attributes.create!(key: "author_name", value: "Author Name #{index}")
          end
          parameter_object = described_class.new(additional_attributes: ["program_name", "author_name"])
          scope = parameter_object.apply_and_return(scope: work.class)

          # Note the array of one element
          expect(scope.all.map(&:program_name)).to eq(["Program Name 1, Program Name 2, Program Name 3"])

          # I wish the count would work, but ActiveRecord can't quite
          # handle all of the antics of the LEFT JOIN with
          # GROUP_CONCAT.
          expect { scope.count }.to raise_error(ActiveRecord::StatementInvalid)
        end
      end
    end
  end
end
