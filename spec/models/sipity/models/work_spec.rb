require 'spec_helper'
require 'sipity/models/work'

module Sipity
  module Models
    RSpec.describe Work, type: :model do
      subject { Work.new(title: 'Hello World') }

      context 'database columns' do
        subject { Work }
        its(:column_names) { is_expected.to include('work_type') }
        its(:column_names) { is_expected.not_to include('work_publication_strategy') }
        its(:column_names) { is_expected.to include('title') }
      end

      it 'will sanitize its title' do
        subject = Work.new(title: '<p>Hello<script>World</script></p>')
        expect(subject.title).to eq('Hello')
      end

      its(:to_s) { is_expected.to eq(subject.title) }

      it { is_expected.to have_many :work_redirect_strategies }
      it { is_expected.to respond_to :processing_strategy }
      it { is_expected.to respond_to :processing_state }
      it { is_expected.to respond_to :work_area }
      it { is_expected.to respond_to :submission_window }
      it { is_expected.to delegate_method(:transition_date).to(:access_right).with_prefix }

      context '#to_rof' do
        it 'should delegate to Conversions::ToRof::WorkConverter' do
          expect(Conversions::ToRof::WorkConverter).to receive(:call).with(work: subject)
          subject.to_rof
        end
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

        it 'accepts "doctoral_dissertation" as an acceptable work_type' do
          expect { subject.work_type = 'doctoral_dissertation' }.to_not raise_error
        end

        it 'will not accept "ETD" as it is case sensitive' do
          expect { subject.work_type = 'ETD' }.to raise_error(ArgumentError)
        end
      end

      it 'has many :additional_attributes' do
        expect(Work.reflect_on_association(:additional_attributes)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'has many :work_submission' do
        expect(Work.reflect_on_association(:work_submission)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'has one :attachments' do
        expect(Work.reflect_on_association(:attachments)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end
    end
  end
end
