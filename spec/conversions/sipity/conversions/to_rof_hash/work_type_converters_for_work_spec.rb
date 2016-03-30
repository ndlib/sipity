require 'spec_helper'
require 'sipity/conversions/to_rof_hash/work_type_converters_for_work'

module Sipity
  RSpec.describe Conversions::ToRofHash::WorkTypeConvertersForWork do
    context '.build' do
      let(:repository) { QueryRepositoryInterface.new }
      let(:base_converter) { double('Base Converter') }
      subject { described_class.build(work: work, repository: repository, base_converter: base_converter) }
      context 'for a Models::WorkType::DOCTORAL_DISSERTATION' do
        let(:work) { Sipity::Models::Work.new(work_type: Models::WorkType::DOCTORAL_DISSERTATION) }
        it { is_expected.to be_a(described_class::EtdConverter) }
      end
      context 'for a Models::WorkType::MASTER_THESIS' do
        let(:work) { Sipity::Models::Work.new(work_type: Models::WorkType::MASTER_THESIS) }
        it { is_expected.to be_a(described_class::EtdConverter) }
      end
      context 'for an unhandled work type' do
        let(:work) { double(work_type: 'coalmine') }
        it 'should raise an Exceptions::FailedToInitializeWorkConverterError' do
          expect { subject }.to raise_error(Exceptions::FailedToInitializeWorkConverterError)
        end
      end
    end
  end
end
