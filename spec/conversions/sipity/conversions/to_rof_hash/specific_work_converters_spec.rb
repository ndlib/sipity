require 'spec_helper'
require 'sipity/conversions/to_rof_hash/specific_work_converters'

module Sipity
  RSpec.describe Conversions::ToRofHash::SpecificWorkConverters do
    context '.find_and_initialize' do
      let(:repository) { QueryRepositoryInterface.new }
      subject { described_class.find_and_initialize(work: work, repository: repository) }
      context 'for a Models::WorkType::DOCTORAL_DISSERTATION' do
        let(:work) { Sipity::Models::Work.new(work_type: Models::WorkType::DOCTORAL_DISSERTATION) }
        it { is_expected.to be_a(described_class::EtdConverter) }
      end
      context 'for a Models::WorkType::MASTER_THESIS' do
        let(:work) { Sipity::Models::Work.new(work_type: Models::WorkType::MASTER_THESIS) }
        it { is_expected.to be_a(described_class::EtdConverter) }
      end

      context 'for a Models::WorkType::ULRA_SUBMISSION' do
        let(:work) { Sipity::Models::Work.new(work_type: Models::WorkType::ULRA_SUBMISSION) }
        {
          '10000 Level' => described_class::UlraDocumentConverter,
          "20000–40000 Level" => described_class::UlraDocumentConverter,
          "Honors Thesis" => described_class::UlraDocumentConverter,
          "Capstone Project" => described_class::UlraDocumentConverter,
          'Senior Thesis' => described_class::UlraSeniorThesisConverter
        }.each_pair do |award_category, converter_class|
          context "with award category #{award_category.inspect}" do
            before { allow(repository).to receive(:work_attribute_values_for).and_return(award_category) }
            it { is_expected.to be_a(converter_class) }
          end
        end
        context "with an unknown award category" do
          before { allow(repository).to receive(:work_attribute_values_for).and_return('Best Haircut') }
          it 'should raise an Exceptions::FailedToInitializeWorkConverterError' do
            expect { subject }.to raise_error(Exceptions::FailedToInitializeWorkConverterError)
          end
        end
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
