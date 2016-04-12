require 'spec_helper'
require 'sipity/conversions/to_rof/work_converter'

module Sipity
  module Conversions
    module ToRof
      RSpec.describe WorkConverter do
        let(:work) { double('Work') }
        let(:converting_instance) { double(to_rof: true, attachments: []) }
        subject { described_class }

        context '.call' do
          it 'should convert the work into a hash' do
            allow(described_class).to receive(:find_and_initialize).and_return(converting_instance)
            subject.call(work: work)
            expect(converting_instance).to have_received(:to_rof)
          end
        end

        context '.attachments_for' do
          it 'should convert the work into an array of Sipity::Model::Attachment' do
            allow(described_class).to receive(:find_and_initialize).and_return(converting_instance)
            subject.attachments_for(work: work)
            expect(converting_instance).to have_received(:attachments)
          end
        end

        its(:default_repository) { is_expected.to respond_to(:scope_users_for_entity_and_roles) }

        context '.find_and_initialize' do
          let(:repository) { QueryRepositoryInterface.new }
          subject { described_class.find_and_initialize(work: work, repository: repository) }
          context 'for a Models::WorkType::DOCTORAL_DISSERTATION' do
            let(:work) { Sipity::Models::Work.new(work_type: Models::WorkType::DOCTORAL_DISSERTATION) }
            it { is_expected.to be_a(WorkConverters::EtdConverter) }
          end
          context 'for a Models::WorkType::MASTER_THESIS' do
            let(:work) { Sipity::Models::Work.new(work_type: Models::WorkType::MASTER_THESIS) }
            it { is_expected.to be_a(WorkConverters::EtdConverter) }
          end

          context 'for a Models::WorkType::ULRA_SUBMISSION' do
            let(:work) { Sipity::Models::Work.new(work_type: Models::WorkType::ULRA_SUBMISSION) }
            {
              '10000 Level' => WorkConverters::UlraDocumentConverter,
              "20000–40000 Level" => WorkConverters::UlraDocumentConverter,
              "Honors Thesis" => WorkConverters::UlraDocumentConverter,
              "Capstone Project" => WorkConverters::UlraDocumentConverter,
              'Senior Thesis' => WorkConverters::UlraSeniorThesisConverter
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
  end
end
