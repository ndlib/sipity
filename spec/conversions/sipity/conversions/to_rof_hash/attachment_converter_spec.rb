require 'spec_helper'
require 'sipity/conversions/to_rof_hash/attachment_converter'

module Sipity
  RSpec.describe Conversions::ToRofHash::AttachmentConverter do
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
    subject { described_class.new(attachment: attachment, repository: repository) }

    it 'exposes .call as a convenience method' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(attachment: attachment)
    end

    its(:default_repository) { is_expected.to respond_to(:scope_users_for_entity_and_roles) }
    its(:default_repository) { is_expected.to respond_to(:attachment_access_right) }
    it { is_expected.to delegate_method(:work).to(:attachment) }

    before do
      allow(repository).to(
        receive(:scope_users_for_entity_and_roles).with(entity: work, roles: 'creating_user').and_return(double(username: 'one-cool-cat'))
      )
      allow(repository).to(
        receive(:attachment_access_right).with(attachment: attachment).and_return(attachment_access_right_data)
      )
    end
    context '#call' do
      subject { described_class.new(attachment: attachment, repository: repository).call }
      it 'will be well formed' do
        # TODO: Work on an ROF schema that can be validated against.
        # SEE: https://github.com/ndlib/rof/issues/15
        hash = subject
        expect(hash.keys).to eq(%w(type pid af-model rights metadata rels-ext properties-meta properties content-meta content-file))
      end
    end

    context '#attachment_specific_access_rights' do
      subject { described_class.new(attachment: attachment, repository: repository).send(:attachment_specific_access_rights) }
      let(:as_of) { Time.zone.today }
      context "for Models::AccessRight::OPEN_ACCESS" do
        let(:attachment_access_right_data) { double(access_right_code: Models::AccessRight::OPEN_ACCESS, transition_date: as_of) }
        it { is_expected.to eq('read-groups' => 'public') }
      end
      context "for Models::AccessRight::RESTRICTED_ACCESS" do
        let(:attachment_access_right_data) { double(access_right_code: Models::AccessRight::RESTRICTED_ACCESS, transition_date: as_of) }
        it { is_expected.to eq('read-groups' => 'restricted') }
      end
      context "for Models::AccessRight::PRIVATE_ACCESS" do
        let(:attachment_access_right_data) { double(access_right_code: Models::AccessRight::PRIVATE_ACCESS, transition_date: as_of) }
        it { is_expected.to eq({}) }
      end
      context "for Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS" do
        let(:attachment_access_right_data) do
          double(access_right_code: Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS, transition_date: as_of)
        end
        it { is_expected.to eq('read-groups' => 'public', 'embargo-date' => as_of.strftime('%Y-%m-%d')) }
      end
      context "for a bad access right code" do
        let(:attachment_access_right_data) { double(access_right_code: 'BAD-BAD-LEROY-BROWN', transition_date: as_of) }
        it "should raise a RuntimeError" do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
