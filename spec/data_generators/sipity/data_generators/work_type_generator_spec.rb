require 'spec_helper'
require 'sipity/data_generators/work_type_generator'

module Sipity
  RSpec.describe DataGenerators::WorkTypeGenerator do
    let(:submission_window) { Models::SubmissionWindow.new(id: 2, slug: 'start', work_area_id: 1) }
    let(:data) { JSON.parse(json) }
    let(:json) do
      doc = <<-HERE
      {
        "work_types": [
          {
            "name": "ulra_submission",
            "strategy_permissions": [{
              "group": "ULRA Review Committee",
              "role": "ulra_reviewer"
            }],
            "actions": [{
              "name": "start_a_submission",
              "transition_to": "new",
              "emails": [{
                "name": "confirmation_of_ulra_submission_started",
                "to": "creating_user"
              }, {
                "name": "faculty_assigned_for_ulra_submission",
                "to": "advisor"
              }]
            }],
            "processing_hooks": [{
              "state": "new",
              "emails": [{
                "name": "student_has_indicated_attachments_are_complete",
                "to": "ulra_reviewer"
              }]
            }]
          }
        ]
      }
      HERE
      doc.strip
    end
    let(:validator) { double(call: true) }
    let(:keywords) { { submission_window: submission_window, data: data, validator: validator } }

    subject { described_class.new(**keywords) }

    its(:default_validator) { should respond_to(:call) }
    its(:default_schema) { should respond_to(:call) }

    it 'exposes .call as a convenience method' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(**keywords)
    end

    it 'validates the data against the schema' do
      subject
      expect(validator).to have_received(:call).with(data: subject.send(:data), schema: subject.send(:schema))
    end

    context 'data generation' do
      let(:keywords) { { submission_window: submission_window, data: data } }
      it 'creates the requisite data' do
        expect(DataGenerators::StateMachineGenerator).to receive(:generate_from_schema).and_call_original.exactly(1).times
        expect(DataGenerators::EmailNotificationGenerator).to receive(:call).and_call_original.exactly(3).times
        expect do
          expect do
            expect do
              expect do
                expect do
                  subject.call
                end.to change { Models::Processing::Strategy.count }.by(1)
              end.to change { Models::Processing::StrategyUsage.count }.by(1)
            end.to change { Models::WorkType.count }.by(1)
          end.to change { Models::SubmissionWindowWorkType.count }.by(1)
        end.to change { Models::Group.count }.by(1)
      end
    end
  end
end
