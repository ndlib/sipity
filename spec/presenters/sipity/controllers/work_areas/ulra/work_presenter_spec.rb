require "rails_helper"

module Sipity
  module Controllers
    module WorkAreas
      module Ulra
        RSpec.describe WorkPresenter do
          let(:repository) { QueryRepositoryInterface.new }
          let(:context) { PresenterHelper::ContextWithForm.new(repository: repository) }
          let(:work) do
            double(
              'Work',
              title: 'hello',
              work_type: 'doctoral_dissertation',
              processing_state: 'new',
              created_at: Time.zone.today,
              submission_window: Models::SubmissionWindow.new(slug: '2017')
            )
          end

          subject { described_class.new(context, work: work) }
          before do
            allow(repository).to(
              receive(:work_attribute_values_for).with(work: work, key: 'award_category', cardinality: :one).and_return("String")
            )
          end
          its(:award_category) { is_expected.to be_a(String) }
        end
      end
    end
  end
end
