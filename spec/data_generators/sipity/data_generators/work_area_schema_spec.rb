require "rails_helper"
require 'sipity/data_generators/schema_validator'

RSpec.describe Sipity::DataGenerators::WorkAreaSchema do
  let(:schema) { described_class }
  subject { Sipity::DataGenerators::SchemaValidator.call(data: data, schema: schema) }

  context 'with valid data' do
    let(:data) do
      {
        work_areas: [{
          attributes: { name: 'Electronic Thesis and Dissertation', slug: 'etd' },
          actions: [{ name: 'show', states: [{ name: 'new', roles: ['WORK_AREA_VIEWING'] }] }],
          strategy_permissions: [{ group: 'ALL_REGISTERED_USERS', role: 'WORK_AREA_VIEWING' }]
        }]
      }
    end

    it 'validates good data' do
      expect(subject).to be_truthy
    end
  end

  [
    "ulra_work_area.config.json",
    "etd_work_area.config.json"
  ].each do |basename|
    context "with #{basename}" do
      let(:data) { JSON.parse(Rails.root.join('app/data_generators/sipity/data_generators/work_areas', basename).read).deep_symbolize_keys }
      it "validates" do
        expect(subject).to be_truthy
      end
    end
  end

  context 'with invalid data' do
    let(:data) do
      {
        work_areas: [{
          attributes: { name: 'Electronic Thesis and Dissertation' },
          actions: [{ name: 'show', states: [{ name: 'new', roles: ['WORK_AREA_VIEWING'] }] }],
          strategy_permissions: [{ group: 'ALL_REGISTERED_USERS', role: 'WORK_AREA_VIEWING' }]
        }]
      }
    end

    it 'invalidates bad data' do
      expect { subject }.to raise_error(Sipity::Exceptions::InvalidSchemaError)
    end
  end
end
