require "rails_helper"
require 'sipity/conversions/to_rof/work_converters/core_converter'

module Sipity
  module Conversions
    module ToRof
      module WorkConverters
        RSpec.describe CoreConverter do
          let(:work) do
            Sipity::Models::Work.new(
              id: 'abcd-ef',
              work_type: 'doctoral_dissertation',
              collaborators: [collaborator],
              access_right: access_right
            )
          end
          let(:access_right) { Sipity::Models::AccessRight.new(access_right_code: Sipity::Models::AccessRight::OPEN_ACCESS) }
          let(:collaborator) { Sipity::Models::Collaborator.new(role: 'Research Director', name: 'Alexander Hamilton') }
          let(:repository) { Sipity::QueryRepositoryInterface.new }
          let(:attachment1) { Sipity::Models::Attachment.new(id: 'attachment-1', is_representative_file: true) }
          let(:attachment2) { Sipity::Models::Attachment.new(id: 'attachment-2', is_representative_file: false) }

          subject { described_class.new(work: work, repository: repository) }
          its(:default_repository) { is_expected.to respond_to :work_attribute_values_for }
          its(:default_attachment_converter) { is_expected.to respond_to :call }
          its(:properties_meta) { is_expected.to be_a(Hash) }
          its(:properties) { is_expected.to be_a(String) }
          it { is_expected.to respond_to(:access_rights) }
          its(:namespaced_pid) { is_expected.to be_a(String) }
          its(:rof_type) { is_expected.to eq(described_class::DEFAULT_ROF_TYPE) }

          %w(af_model rels_ext metadata edit_groups).each do |method_name|
            context "##{method_name}" do
              it "requires subclass to define the method" do
                expect { subject.public_send(method_name) }.to raise_error NotImplementedError
              end
            end
          end

          context '#attachments' do
            it 'will return an array of all attachments with the representative first' do
              expect(repository).to(
                receive(:work_attachments).with(
                  work: work, predicate_name: :all, order: :representative_first
                ).and_return([attachment1, attachment2])
              )
              expect(subject.attachments).to eq([attachment1, attachment2])
            end
          end

          context '#to_hash' do
            let(:converter) { described_class.new(work: work, repository: repository) }
            subject { converter.to_hash }
            context 'when af_model, rels_ext, and metadata are overridden' do
              before do
                expect(converter).to receive(:af_model).and_return('OVERRIDE')
                expect(converter).to receive(:rels_ext).and_return({})
                expect(converter).to receive(:metadata).and_return({})
                expect(converter).to receive(:edit_groups).and_return(['hello world'])
                expect(repository).to receive(:representative_attachment_for).with(work: work).and_return(attachment1)
              end
              it { is_expected.to be_a(Hash) }

              it 'will not have a files key (as the representative is set via the properties)' do
                expect { subject.fetch('files') }.to raise_error(KeyError)
              end

              it 'will have a representative property' do
                expect(subject.fetch('properties')).to include("<representative>und:#{attachment1.to_param}</representative>")
              end
            end
            context 'when af_model, rels_ext, and metadata are NOT overridden' do
              it 'should raise an exception' do
                expect { subject }.to raise_error NotImplementedError
              end
            end
          end

          context '#to_rof' do
            let(:converter) { described_class.new(work: work, repository: repository, attachment_converter: attachment_converter) }
            let(:attachment_converter) { double("Attachment Converter", call: true) }
            subject { converter.to_rof }
            context 'when #to_hash and #attachments are defined' do
              before do
                expect(converter).to receive(:af_model).and_return('OVERRIDE')
                expect(converter).to receive(:rels_ext).and_return({})
                expect(converter).to receive(:metadata).and_return({})
                expect(converter).to receive(:edit_groups).and_return(['hello world'])
                expect(repository).to receive(:work_attachments).and_return([attachment1])
                expect(attachment_converter).to receive(:call).with(
                  attachment: attachment1, repository: repository, work_converter: converter
                ).and_return(converted: 'attachment')
              end
              it { is_expected.to be_a(Array) }
            end
          end
        end
      end
    end
  end
end
