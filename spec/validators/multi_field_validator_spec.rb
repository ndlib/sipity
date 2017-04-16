require 'spec_helper'

describe MultiFieldValidator do
  let(:validatable) do
    Class.new do
      def self.name
        'Validatable'
      end
      include ActiveModel::Validations
      attr_accessor :arr
      validates :arr, multi_field: true
    end
  end

  subject { MultiFieldValidator.new(validator_parameters) }
  let(:validator_parameters) { { attributes: { arr: ["one", "two"] } } }

  context 'with multi_field' do
    it { expect(:valid?).to be_truthy }
  end

  context '#validate_each' do
    let(:arr) { ["one", "two"] }

    it 'will add an error to the given attribute if the remote validator returns false' do
      record = validatable.new
      validator = described_class.new(validator_parameters)
      validator.validate_each(record, :arr, [" "])
      expect(record.errors.messages).not_to be_empty
    end

    it 'will not add an error to the given attribute if the validator returns true' do
      record = validatable.new
      validator = described_class.new(validator_parameters)
      validator.validate_each(record, :arr, ["one", "two"])
      expect(record.errors.messages).to be_empty
    end

  end
end
