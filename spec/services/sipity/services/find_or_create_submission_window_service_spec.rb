require 'rails_helper'

module Sipity
  module Services
    RSpec.describe FindOrCreateSubmissionWindowService do
      subject { described_class }
      let(:work_area) { Models::WorkArea.new(slug: 'etd', id: 1) }
      let(:strategy_id) { 888_999_111 }
      let(:slug) { 'start' }
      it 'will create a submission window for the given work area' do
        expect { subject.call(slug: slug, work_area: work_area) }.
          to change(Models::SubmissionWindow, :count).by(1)
      end
      it 'will yield the created submission window' do
        expect { |b| subject.call(slug: slug, work_area: work_area, &b) }.
          to yield_with_args(Models::SubmissionWindow)
      end

      it 'will reuse an existing strategy usage for the given work area' do
        another_submission_window = Models::SubmissionWindow.create!(slug: 'start-2', work_area_id: work_area.id)
        Models::Processing::StrategyUsage.create!(usage: another_submission_window, strategy_id: strategy_id)

        expect { subject.call(slug: slug, work_area: work_area) }.
          to change { Models::Processing::StrategyUsage.where(strategy_id: strategy_id).count }.by(1)
      end
    end
  end
end
