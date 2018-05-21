require "rails_helper"
require 'sipity/data_generators/work_type_generator'

module Sipity
  RSpec.describe DataGenerators::WorkTypeGenerator do
    let(:submission_window) { Models::SubmissionWindow.new(id: 2, slug: 'start', work_area_id: 1) }
    let(:path) { double(read: json) }
    let(:json) do
      doc = <<-HERE
      {
        "work_types": [
          {
            "name": "ulra_submission",
            "strategy_permissions": [{
              "group": "ULRA Review Committee",
              "role": "ulra_reviewing"
            }],
            "actions": [{
              "name": "start_a_submission",
              "transition_to": "new",
              "emails": [{
                "name": "confirmation_of_ulra_submission_started",
                "to": ["creating_user"]
              },{
                "name": "faculty_assigned_for_ulra_submission",
                "to": ["advising"]
              }]
            },{
              "name": "start"
            }],
            "action_analogues": [{
              "action": "start_a_submission", "analogous_to": "start"
            }],
            "state_emails": [{
              "state": "new",
              "reason": "processing_hook_triggered",
              "emails": [{
                "name": "student_has_indicated_attachments_are_complete",
                "to": ["ulra_reviewing"]
              }]
            }]
          }
        ]
      }
      HERE
      doc.strip
    end
    let(:validator) { double(call: true) }

    subject { described_class.new(submission_window: submission_window, data: {}, validator: validator) }

    its(:default_validator) { is_expected.to respond_to(:call) }
    its(:default_schema) { is_expected.to respond_to(:call) }

    it 'exposes .generate_from_json_file as a convenience method' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.generate_from_json_file(submission_window: submission_window, path: path, validator: validator)
    end

    it 'validates the data against the schema' do
      subject
      expect(validator).to have_received(:call).with(data: subject.send(:data), schema: subject.send(:schema))
    end

    context '.generate_from_json_file' do
      # Should I be testing a production file?
      let(:path) { Rails.root.join('app/data_generators/sipity/data_generators/work_types/ulra_work_types.config.json').to_s }

      it 'will load the file and parse as JSON' do
        expect_any_instance_of(described_class).to receive(:call)
        described_class.generate_from_json_file(submission_window: submission_window, path: path)
      end
    end

    context 'data generation' do
      it 'creates the requisite data' do
        expect(DataGenerators::EmailNotificationGenerator).to receive(:call).and_call_original.exactly(3).times
        expect_any_instance_of(DataGenerators::StrategyPermissionsGenerator).to receive(:call)
        expect(DataGenerators::ProcessingActionsGenerator).to receive(:call).and_call_original
        expect do
          expect do
            expect do
              expect do
                expect do
                  described_class.generate_from_json_file(submission_window: submission_window, path: path)
                end.to change { Models::Processing::StrategyActionAnalogue.count }.by(1)
              end.to change { Models::Processing::Strategy.count }.by(1)
            end.to change { Models::Processing::StrategyUsage.count }.by(1)
          end.to change { Models::WorkType.count }.by(1)
        end.to change { Models::SubmissionWindowWorkType.count }.by(1)
      end
    end
  end
end
