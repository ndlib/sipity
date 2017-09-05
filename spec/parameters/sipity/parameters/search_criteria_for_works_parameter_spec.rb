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
      its(:default_per) { is_expected.to eq(15) }
      its(:default_user) { is_expected.to eq(nil) }
      its(:default_proxy_for_type) { is_expected.to eq(Models::Work) }
      its(:default_processing_state) { is_expected.to eq(nil) }
      its(:default_work_area) { is_expected.to eq(nil) }
      its(:default_submission_window) { is_expected.to eq(nil) }
      its(:default_order) { is_expected.to eq('title'.freeze) }

      it 'will fallback on default order if an invalid order is given' do
        subject = described_class.new(order: 'chicken-sandwich')
        expect(subject.order).to eq(subject.send(:default_order))
      end

      it 'will fallback to no page if :all is given' do
        subject = described_class.new(page: :all)
        expect(subject.page).to be_nil
      end
    end
  end
end
