require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe AdministrativeScheduledActionQueries, type: :isolated_repository_module do
      context '#scheduled_action_from_work' do
        let(:work) { Models::Work.new(id: '123') }
        let(:entity) { double(Sipity::Models::Processing::Entity) }
        let(:scheduled_time) { "01-01-2001" }
        let(:reason) { "notify_cataloging" }
        let(:scheduled_action) { double(scheduled_time: scheduled_time, reason: reason) }

        subject { test_repository }

        it 'will get scheduled_time from work' do
          expect(PowerConverter).to receive(:convert).with(work, to: :processing_entity).and_return(entity)
          expect(Models::Processing::AdministrativeScheduledAction).
            to receive_message_chain(:where, :pluck).
            and_return([scheduled_time])
          subject.scheduled_time_from_work(work: work, reason: reason)
        end
      end
    end
  end
end
