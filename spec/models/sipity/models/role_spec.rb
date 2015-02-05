require 'rails_helper'

module Sipity
  module Models
    RSpec.describe Role, type: :model do
      context 'class methods' do
        subject { described_class }
        its(:column_names) { should include('name') }
        its(:column_names) { should include('description') }
        context '.[]' do
          let(:valid_name) { described_class.valid_names.first }
          it 'will find the named role' do
            expected_object = described_class.create!(name: valid_name)
            expect(described_class[valid_name]).to eq(expected_object)
          end
          it 'will raise an exception if no named role' do
            expect { described_class['string'] }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      subject { described_class.new }
      it 'will raise an ArgumentError if you provide an invalid name' do
        expect { subject.name = '__incorrect_name__' }.to raise_error(ArgumentError)
      end

      it 'will have a #to_s that is a name' do
        subject.name = 'advisor'
        expect(subject.to_s).to eq(subject.name)
      end
    end
  end
end
