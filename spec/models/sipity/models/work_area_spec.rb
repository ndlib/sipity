require 'rails_helper'

module Sipity
  module Models
    RSpec.describe WorkArea, type: :model do
      context 'database configuration' do
        subject { described_class }
        its(:column_names) { should include('slug') }
        its(:column_names) { should include('partial_suffix') }
        its(:column_names) { should include('demodulized_class_prefix_name') }
        its(:column_names) { should include('name') }
      end

      subject { described_class.new }

      it 'will have a #to_s equal to its name' do
        subject.name = 'hello'
        expect(subject.to_s).to eq(subject.name)
      end

      it 'will have one .strategy_usage' do
        expect(subject.association(:strategy_usage)).to be_a(ActiveRecord::Associations::HasOneAssociation)
      end

      context '#to_processing_entity' do
        it 'will raise an exception if one has not been created' do
          expect { subject.to_processing_entity }.to raise_error(Exceptions::ProcessingEntityConversionError)
        end
        it 'will return the existing process entity' do
          expect_processing_entity = subject.build_processing_entity
          expect(subject.to_processing_entity).to eq(expect_processing_entity)
        end
      end

      it 'will have many .submission_windows' do
        expect(subject.submission_windows).to be_a(ActiveRecord::Relation)
      end

      context '#slug' do
        it 'will transform the slug to a URI safe item' do
          subject.slug = 'Hello World'
          expect(subject.slug).to eq('hello-world')
        end
      end

      context '#partial_suffix' do
        it 'will transform the partial_suffix to a file system safe string' do
          subject.partial_suffix = 'Hello World'
          expect(subject.partial_suffix).to eq('hello-world')
        end
      end

      context '#demodulized_class_prefix_name' do
        it 'will transform the demodulized_class_prefix_name' do
          subject.demodulized_class_prefix_name = 'Hello World'
          expect(subject.demodulized_class_prefix_name).to eq('HelloWorld')
        end
      end
    end
  end
end
