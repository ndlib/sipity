require 'rails_helper'

module Sipity
  module Models
    RSpec.describe WorkType, type: :model do
      context '.[]' do
        it 'will have an ETD' do
          described_class.create!(name: 'doctoral_dissertation')
          expect(described_class['doctoral_dissertation']).to be_a(WorkType)
        end

        it 'will raise an exception if the WorkType is invalid' do
          expect { described_class['__MISSIN__'] }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      it 'will have many .submission_window_work_types' do
        expect(subject.submission_window_work_types).to be_a(ActiveRecord::Relation)
      end

      context '.all_for_enum_configuration' do
        it 'will be a Hash to appease the enum interface' do
          expect(described_class.all_for_enum_configuration).to be_a(Hash)
        end
      end

      context '.valid_names' do
        it 'will be an Array' do
          expect(described_class.valid_names).to be_a(Array)
        end
      end

      it 'has one :default_processing_strategy' do
        expect(described_class.reflect_on_association(:default_processing_strategy)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'has one :strategy_usage' do
        expect(subject.association(:strategy_usage)).to be_a(ActiveRecord::Associations::HasOneAssociation)
      end

      context '#find_or_initialize_default_processing_strategy' do
        subject { described_class.new(name: 'doctoral_dissertation') }
        it 'will create a processing strategy if none already exist' do
          expect { subject.find_or_initialize_default_processing_strategy }.
            to change { subject.default_processing_strategy }.from(nil)
        end

        it 'will yield the processing' do
          expect { |b| subject.find_or_initialize_default_processing_strategy(&b) }.to yield_control
        end
      end
    end
  end
end
