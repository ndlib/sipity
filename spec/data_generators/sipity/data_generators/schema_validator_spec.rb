require "rails_helper"
require 'sipity/data_generators/schema_validator'

module Sipity
  RSpec.describe DataGenerators::SchemaValidator do
    context '.call' do
      let(:data) { { name: 'Hello' } }

      context 'with a dry-validation schema' do
        let(:schema) do
          Dry::Schema.JSON do
            required(:name).filled(:str?)
          end
        end

        it 'returns true if the given data has a valid schema' do
          expect(described_class.call(data: { name: 'Hello' }, schema: schema)).to eq(true)
        end

        it 'raises an exception with messages if the given data has an invalid schema' do
          expect { described_class.call(data: {}, schema: schema) }.to raise_error(Exceptions::InvalidSchemaError)
        end
      end
    end
  end
end
