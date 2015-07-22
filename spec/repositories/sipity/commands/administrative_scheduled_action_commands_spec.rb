require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe AdministrativeScheduledActionCommands, type: :command_with_related_query do
      # TODO: These are horribly comingled with the queries.
      #   Need to tease those apart.
      # Because of enum enforcement I need real key names
      let(:work) { Models::Work.new(id: '123', title: "My title") }
      let(:scheduled_time) { "01-01-2001" }
      let(:reason) { "notify_cataloging" }
      let(:entity) { double(Sipity::Models::Processing::Entity) }

      subject { test_repository }

      context "#create_scheduled_action" do
        it 'will create administrative_scheduled_action record' do
          expect(PowerConverter).to receive(:convert).with(work, to: :processing_entity).and_return(entity)
          expect(Models::Processing::AdministrativeScheduledAction).
            to receive(:create!).
            with(entity: entity, scheduled_time: scheduled_time, reason: reason).
            and_return(nil)
          subject.create_scheduled_action(work: work, scheduled_time: scheduled_time, reason: reason)
        end
      end
    end
  end
end
