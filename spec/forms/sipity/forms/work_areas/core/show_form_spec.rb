require "rails_helper"
require 'sipity/forms/work_areas/core/show_form'
require 'sipity/forms/work_areas/core/show_form'

module Sipity
  module Forms
    module WorkAreas
      module Core
        RSpec.describe ShowForm do
          let(:work_area) { double(name: 'Hello Name', slug: 'hello-world') }
          let(:repository) { QueryRepositoryInterface.new }
          let(:user) { double }
          subject { described_class.new(work_area: work_area, requested_by: user, repository: repository) }

          its(:policy_enforcer) { is_expected.to eq Sipity::Policies::WorkAreaPolicy }
          its(:processing_action_name) { is_expected.to eq('show') }
          it { is_expected.to implement_processing_form_interface }
          it { is_expected.to delegate_method(:name).to(:work_area) }
          it { is_expected.to delegate_method(:slug).to(:work_area) }

          its(:order_options_for_select) { is_expected.to be_a(Array) }
          its(:input_name_for_select_processing_states) { is_expected.to eq('work_area[processing_states][]') }
          its(:input_name_for_select_sort_order) { is_expected.to eq('work_area[order]') }
          its(:input_name_for_selecting_submission_window) { is_expected.to eq('work_area[submission_window]') }
          its(:input_name_for_q) { is_expected.to eq('work_area[q]') }
          its(:page) { is_expected.to eq(subject.send(:default_page)) }

          it { is_expected.to delegate_method(:default_order).to(:search_criteria_config) }
          it { is_expected.to delegate_method(:default_page).to(:search_criteria_config) }
          it { is_expected.to delegate_method(:order_options_for_select).to(:search_criteria_config) }

          it 'will expose #processing_states_for_select' do
            expect(repository).to receive(:processing_state_names_for_select_within_work_area).with(work_area: work_area).and_call_original
            subject.processing_states_for_select
          end

          it 'will expose #submission_windows_for_select' do
            expect(repository).to receive(:submission_window_names_for_select_within_work_area).with(work_area: work_area).and_call_original
            subject.submission_windows_for_select
          end
        end
      end
    end
  end
end
