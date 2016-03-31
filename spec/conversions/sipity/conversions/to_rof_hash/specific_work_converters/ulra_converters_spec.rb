require 'spec_helper'
require 'sipity/conversions/to_rof_hash/specific_work_converters/ulra_converters'

module Sipity
  module Conversions
    module ToRofHash
      module SpecificWorkConverters
        RSpec.describe UlraSeniorThesisConverter do
          let(:work) { double }
          let(:repository) { Sipity::QueryRepositoryInterface.new }
          subject { described_class.new(work: work, repository: repository) }
          its(:af_model) { is_expected.to eq('SeniorThesis') }
          # xits(:metadata) { is_expected.to be_a(Hash) }
          # xits(:rels_ext) { is_expected.to be_a(Hash) }
        end
        RSpec.describe UlraDocumentConverter do
          let(:work) { double }
          let(:repository) { Sipity::QueryRepositoryInterface.new }
          subject { described_class.new(work: work, repository: repository) }
          its(:af_model) { is_expected.to eq('Document') }
          # its(:metadata) { is_expected.to be_a(Hash) }
          # its(:rels_ext) { is_expected.to be_a(Hash) }
        end
      end
    end
  end
end
