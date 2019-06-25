require "rails_helper"

RSpec.describe Sipity::DataGenerators::WorkTypeSchema do
  let(:schema) { described_class }
  subject { Sipity::DataGenerators::SchemaValidator.call(data: data, schema: schema) }

  context 'with valid data' do
    let(:data) do
      {
        work_types: [
          {
            name: 'ulra_submission',
            strategy_permissions: [
              { group: 'ULRA Review Committee', role: "ulra_reviewing" }
            ],
            actions: [
              {
                name: 'start_a_submission',
                transition_to: 'new',
                emails: [
                  { name: 'confirmation_of_ulra_submission_started', to: ['creating_user'] },
                  { name: 'faculty_assigned_for_ulra_submission', to: ['advising'] }
                ],
                states: [
                  { name: 'under_review', roles: "ulra_reviewing" },
                  { name: 'something_else', roles: ["ulra_reviewing"] }
                ],
                attributes: { presentation_sequence: 1 },
                required_actions: ['something']
              }, {
                name: 'something',
                transition_to: 'new',
                states: [
                  { name: 'something_else', roles: ["ulra_reviewing"] }
                ]
              }
            ],
            state_emails: [
              {
                state: 'under_review',
                reason: 'processing_hook_triggered',
                emails: [
                  { name: 'student_has_indicated_attachments_are_complete', to: ["ulra_reviewing"] }
                ]
              }
            ],
            action_analogues: [
              { action: 'start_a_submission', analogous_to: 'something' }
            ]
          }
        ]
      }
    end

    it 'validates' do
      expect(subject).to be_truthy
    end
  end

  context 'with invalid data' do
    let(:data) do
      {
        work_types: [{ actions: [], name: 'wonky', state_emails: [{ state: 'under_review', email: 'hello', reason: 'chicken_dinner' }] }]
      }
    end
    it "does not validate" do
      expect { subject }.to raise_error(Sipity::Exceptions::InvalidSchemaError)
    end
  end

  [
    "ulra_work_types.config.json",
    "etd_work_types.config.json"
  ].each do |basename|
    context "with #{basename} data" do
      let(:data) { JSON.parse(Rails.root.join('app/data_generators/sipity/data_generators/work_types', basename).read).deep_symbolize_keys }
      it "validates" do
        expect(subject).to be_truthy
      end
    end
  end
end
