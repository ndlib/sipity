require 'spec_helper'
require 'sipity/conversions/to_rof_hash/work_converter'

module Sipity
  RSpec.describe Conversions::ToRofHash::WorkConverter do
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
    subject { described_class.new(work: work, repository: repository) }

    it 'exposes .call as a convenience method' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(work: work)
    end

    its(:default_repository) { is_expected.to respond_to(:scope_users_for_entity_and_roles) }

    its(:call) { is_expected.to be_a(Hash) }
  end
end
