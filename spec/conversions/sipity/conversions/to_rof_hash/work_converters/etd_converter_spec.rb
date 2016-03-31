require 'spec_helper'
require 'sipity/conversions/to_rof_hash/work_converters/etd_converter'

module Sipity
  module Conversions
    module ToRofHash
      module WorkConverters
        RSpec.describe EtdConverter do
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
          let(:repository) { Sipity::QueryRepositoryInterface.new }
          subject { described_class.new(work: work, repository: repository) }
          its(:af_model) { is_expected.to eq('Etd') }
          its(:edit_groups) { is_expected.to be_a(Array) }
          its(:metadata) { is_expected.to be_a(Hash) }
          its(:rels_ext) { is_expected.to be_a(Hash) }
          its(:to_hash) { is_expected.to be_a(Hash) }
        end
      end
    end
  end
end
