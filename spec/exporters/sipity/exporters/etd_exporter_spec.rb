require 'spec_helper'

module Sipity
  module Exporters
    RSpec.describe EtdExporter do
      let(:access_right) { ['private_access'] }
      let(:work) { double(Sipity::Models::Work) }
      let(:repository) { QueryRepositoryInterface.new }
      let(:creators) { [double(username: 'Hello')] }
      let(:title) { 'Title of the work' }
      let(:batch_user) { 'curate_batch_user' }
      let(:file) { double }
      let(:json_array) { ["etd_to_json", "attachment_to_json"] }
      let(:etd_mapping_hash) do
        {
          creator: "dc:creator",
          title: "dc:title",
          alternate_title: "dc:title#alternate",
          subject: "dc:subject"
        }
      end

      subject { described_class.new(work, repository: repository) }

      its(:default_repository) { should respond_to :work_attachments }

      it 'will instantiate then call the instance' do
        expect(described_class).to receive(:new).and_return(double(call: true))
        described_class.call(work)
      end

      context '.etd_attributes' do
        it 'will be a Hash of etd attributes' do
          expect(described_class.etd_attributes).to be_a(Hash)
        end
      end

      context 'etd mapping constants' do
        it "will expose ETD mapping" do
          etd_mapping_hash.each do |key, value|
            expect(described_class.etd_attributes[key]).to eq(value)
          end
        end
      end

      context 'export_to_json' do
        it 'will create ROF JSON for given work' do
          expect(repository).to receive(:work_attachments).with(work: work).and_return([file])
          expect(Mappers::EtdMapper).to receive(:call).with(work).
            and_return("etd_to_json")
          expect(Mappers::GenericFileMapper).to receive(:call).with(file).
            and_return("attachment_to_json")
          expect(subject.export_to_json).to eq(json_array)
        end
      end

      context 'call' do
        let(:work_area) { double(Sipity::Models::WorkArea) }
        let(:entity) { double(Sipity::Models::Processing::Entity) }
        let(:strategy_state) { double(Sipity::Models::Processing::StrategyState) }
        let(:ingested_strategy_state) { double(Sipity::Models::Processing::StrategyState) }
        it 'will send ROF JSON to ROF api to ingest into configured fedora' do
          allow(work).to receive(:id).and_return('a_id')

          PowerConverter.should_receive(:convert_to_work_area).with('etd').and_return(work_area)
          allow(work).to receive(:work_area).and_return(work_area)

          expect(Conversions::ConvertToProcessingEntity).to receive(:call).with(work).and_return(entity)
          expect(entity).to receive(:strategy_state).and_return(strategy_state)
          expect(strategy_state).to receive(:name).and_return('ready_for_ingest')
          expect(entity).to receive(:strategy_id).and_return(1)
          expect(ingested_strategy_state).to receive(:id).and_return(1)
          expect(Sipity::Models::Processing::StrategyState).to receive(:where).and_return([ingested_strategy_state])
          expect(entity).to receive(:strategy_state_id=).with(1)
          expect(entity).to receive(:save!)

          expect(repository).to receive(:work_attachments).with(work: work).and_return([file])
          expect(subject).to receive(:export_to_json).
            and_return(["rof json array"])
          expect(FileUtils).to receive(:mv)
          subject.call
        end
      end
    end
  end
end
