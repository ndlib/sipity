require 'spec_helper'
require 'sipity/conversions/to_rof/access_rights_builder'

module Sipity
  RSpec.describe Conversions::ToRof::AccessRightsBuilder do
    let(:work) { Sipity::Models::Work.new(id: 'abcd-ef') }
    let(:access_rights_data) { double(access_right_code: Models::AccessRight::OPEN_ACCESS) }
    let(:repository) { Sipity::QueryRepositoryInterface.new }

    it 'exposes .to_hash as a convenience method' do
      expect_any_instance_of(described_class).to receive(:to_hash)
      described_class.to_hash(work: work, access_rights_data: access_rights_data, repository: repository)
    end

    before do
      allow(repository).to(
        receive(:scope_users_for_entity_and_roles).with(entity: work, roles: 'creating_user').and_return(double(username: 'one-cool-cat'))
      )
    end
    subject { described_class.new(work: work, access_rights_data: access_rights_data, repository: repository) }
    its(:default_repository) { is_expected.to respond_to(:scope_users_for_entity_and_roles) }

    context '#to_hash' do
      let(:expected_base_rights) do
        {
          "edit" => ["curate_batch_user"],
          "edit-groups" => [],
          "read" => ["one-cool-cat"]
        }
      end
      subject { described_class.to_hash(work: work, access_rights_data: access_rights_data, repository: repository) }
      let(:as_of) { Time.zone.today }
      context "for Models::AccessRight::OPEN_ACCESS" do
        let(:access_rights_data) { double(access_right_code: Models::AccessRight::OPEN_ACCESS, transition_date: as_of) }
        it { is_expected.to eq(expected_base_rights.merge('read-groups' => ['public'])) }
      end
      context "for Models::AccessRight::RESTRICTED_ACCESS" do
        let(:access_rights_data) { double(access_right_code: Models::AccessRight::RESTRICTED_ACCESS, transition_date: as_of) }
        it { is_expected.to eq(expected_base_rights.merge('read-groups' => ['restricted'])) }
      end
      context "for Models::AccessRight::PRIVATE_ACCESS" do
        let(:access_rights_data) { double(access_right_code: Models::AccessRight::PRIVATE_ACCESS, transition_date: as_of) }
        it { is_expected.to eq(expected_base_rights) }
      end
      context "for Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS" do
        let(:access_rights_data) do
          double(access_right_code: Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS, transition_date: as_of)
        end
        it { is_expected.to eq(expected_base_rights.merge('read-groups' => ['public'], 'embargo-date' => as_of.strftime('%Y-%m-%d'))) }
      end
      context "for a bad access right code" do
        let(:access_rights_data) { double(access_right_code: 'BAD-BAD-LEROY-BROWN', transition_date: as_of) }
        it "should raise a RuntimeError" do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
