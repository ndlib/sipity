require 'spec_helper'
require 'sipity/conversions/to_rof/attachment_converter'
require 'sipity/conversions/to_rof/work_converters/etd_converter'

module Sipity
  RSpec.describe Conversions::ToRof::AttachmentConverter do
    let(:work_converter) { Conversions::ToRof::WorkConverters::EtdConverter.new(repository: repository, work: work) }
    let(:work) { Sipity::Models::Work.new(id: 'abcd-ef') }
    let(:attachment) do
      Sipity::Models::Attachment.new(
        id: '1234-56',
        file: File.new(__FILE__),
        created_at: Time.zone.today,
        updated_at: Time.zone.today,
        work: work
      )
    end
    let(:attachment_access_right_data) { double(access_right_code: Models::AccessRight::OPEN_ACCESS) }
    let(:repository) { Sipity::QueryRepositoryInterface.new }
    subject { described_class.new(attachment: attachment, work_converter: work_converter, repository: repository) }

    it 'exposes .call as a convenience method' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(attachment: attachment, work_converter: work_converter)
    end

    its(:default_repository) { is_expected.to respond_to(:scope_users_for_entity_and_roles) }
    its(:default_repository) { is_expected.to respond_to(:attachment_access_right) }
    it { is_expected.to delegate_method(:work).to(:work_converter) }
    it { is_expected.to delegate_method(:namespaced_pid).to(:work_converter) }
    it { is_expected.to delegate_method(:edit_groups).to(:work_converter) }

    before do
      allow(repository).to(
        receive(:scope_users_for_entity_and_roles).with(entity: work, roles: 'creating_user').and_return(double(username: 'one-cool-cat'))
      )
      allow(repository).to(
        receive(:attachment_access_right).with(attachment: attachment).and_return(attachment_access_right_data)
      )
    end
    context '#call' do
      subject { described_class.new(attachment: attachment, repository: repository, work_converter: work_converter).call }
      it 'will be well formed' do
        # TODO: Work on an ROF schema that can be validated against.
        # SEE: https://github.com/ndlib/rof/issues/15
        hash = subject
        expect(hash.keys).to eq(%w(type pid af-model rights metadata rels-ext properties-meta properties content-meta content-file))
      end
    end
  end
end
