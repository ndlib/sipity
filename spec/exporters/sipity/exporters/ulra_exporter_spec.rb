require 'spec_helper'
require 'sipity/exporters/ulra_exporter'

module Sipity
  module Exporters
    RSpec.describe UlraExporter do
      let(:access_right) { ['private_access'] }
      let(:work) { Sipity::Models::Work.new(id: 'abc123') }
      let(:repository) { QueryRepositoryInterface.new }
      let(:creators) { [double(username: 'Hello')] }
      let(:title) { 'Title of the work' }
      let(:batch_user) { 'curate_batch_user' }
      let(:file) { double }
      let(:json_array) { ["etd_to_json", "attachment_to_json"] }

      subject { described_class.new(work, repository: repository) }

      its(:default_repository) { should respond_to :work_attachments }
      its(:webhook_authorization_credentials) { should be_a(String) }

      # The .json is important as it helps this Rails application negotiate the content. Without the .json,
      # the batch ingest process is posting a "Content-Type: application/json" but Rails is falling back to
      # an HTML response; Which doesn't work because the HTML template does not exist.
      its(:webhook_url) { should match(%r{/work_submissions/#{work.to_param}/callback/ingest_completed.json$}) }

      it 'will instantiate then call the instance' do
        expect(described_class).to receive(:new).and_return(double(call: true))
        described_class.call(work)
      end

      context 'export_to_json' do
        it 'will create ROF JSON for given work' do
          expect(repository).to receive(:work_attachments).with(work: work).and_return([file])
          expect(Mappers::UlraMapper).to receive(:call).with(work, attribute_map: kind_of(Hash), mount_data_path: kind_of(String)).
            and_return("etd_to_json")
          expect(Mappers::GenericFileMapper).to receive(:call).with(file, attribute_map: kind_of(Hash), mount_data_path: kind_of(String)).
            and_return("attachment_to_json")
          expect(subject.export_to_json).to eq(json_array)
        end
      end

      context 'call' do
        it 'will send ROF JSON to ROF api to ingest into configured fedora' do
          allow(work).to receive(:id).and_return('a_id')
          expect(repository).to receive(:work_attachments).with(work: work).and_return([file])
          expect(subject).to receive(:export_to_json).
            and_return(["rof json array"])
          expect(FileUtils).to receive(:mv)
          expect(subject).to receive(:create_webook).and_call_original
          subject.call
        end
      end
    end
  end
end
