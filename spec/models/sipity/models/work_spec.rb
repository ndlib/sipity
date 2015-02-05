require 'spec_helper'

module Sipity
  module Models
    RSpec.describe Work, type: :model do
      subject { Work.new }

      context 'database columns' do
        subject { Work }
        its(:column_names) { should include('processing_state') }
        its(:column_names) { should include('work_type') }
        its(:column_names) { should include('work_publication_strategy') }
        its(:column_names) { should include('title') }
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

      context '.work_types' do
        it 'is a Hash of keys that equal their values' do
          expect(Work.work_types.keys).
            to eq(Work.work_types.values)
        end
      end

      context '#work_type' do
        it 'will raise an ArgumentError if you provide an invalid work_type' do
          expect { subject.work_type = '__incorrect_work_type__' }.to raise_error(ArgumentError)
        end

        it 'accepts "etd" as an acceptable work_type' do
          expect { subject.work_type = 'etd' }.to_not raise_error
        end

        it 'will not accept "ETD" as it is case sensitive' do
          expect { subject.work_type = 'ETD' }.to raise_error(ArgumentError)
        end
      end

      context '.work_publication_strategies' do
        it 'is a Hash of keys that equal their values' do
          expect(Work.work_publication_strategies.keys).
            to eq(Work.work_publication_strategies.values)
        end
      end

      it 'will raise an ArgumentError if you provide an invalid work_publication_strategy' do
        expect { subject.work_publication_strategy = '__incorrect_strategy__' }.to raise_error(ArgumentError)
      end

      it 'has many :additional_attributes' do
        expect(Work.reflect_on_association(:additional_attributes)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'has many :attachments' do
        expect(Work.reflect_on_association(:attachments)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'has one :doi_creation_request' do
        expect(Work.reflect_on_association(:doi_creation_request)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end
    end
  end
end
