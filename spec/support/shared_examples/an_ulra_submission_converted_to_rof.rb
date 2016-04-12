require 'support/shared_examples/a_work_to_rof_converter'

module Sipity
  RSpec.shared_examples 'an ulra submission converted to ROF' do |parameters|
    it_behaves_like 'a work to rof converter', parameters
    let(:work) do
      Models::Work.new(id: 'abcd-ef', access_right: access_right, created_at: Time.zone.today)
    end
    let(:access_right) { Models::AccessRight.new(access_right_code: Models::AccessRight::OPEN_ACCESS) }
    let(:collaborator) { Models::Collaborator.new(role: Models::Collaborator::ADVISING_FACULTY_ROLE, name: 'Alexander Hamilton') }
    let(:repository) { QueryRepositoryInterface.new }
    let(:converter) { described_class.new(work: work, repository: repository) }

    context '#advising_faculty' do
      subject { converter.advising_faculty }
      before do
        expect(repository).to(
          receive(:work_collaborator_names_for).with(work: work, role: Models::Collaborator::ADVISING_FACULTY_ROLE).and_return('Bob')
        )
      end
      it { is_expected.to be_a(Array) }
    end

    context '#to_hash' do
      subject { converter.to_hash }
      its(:keys) { is_expected.to include('collections') }
    end

    context '#collections' do
      subject { converter.collections }
      let(:is_an_award_winner) { false }
      before do
        allow(repository).to receive(:collection_pid_for).with(submission_window: work, key: 'participant').and_return('abc:123')
        allow(repository).to receive(:collection_pid_for).with(submission_window: work, key: 'award_recipient').and_return('efg:456')
        allow(repository).to receive(:work_attribute_values_for).with(
          work: work, cardinality: 1, key: 'is_an_award_winner'
        ).and_return(is_an_award_winner)
      end
      context 'when an award recipient' do
        let(:is_an_award_winner) { true }
        it { is_expected.to eq(['abc:123', 'efg:456']) }
      end
      context 'when not an award recipient' do
        let(:is_an_award_winner) { false }
        it { is_expected.to eq(['abc:123']) }
      end
    end

    context 'ATTACHMENT_TYPES_FOR_EXPORT' do
      subject { described_class::ATTACHMENT_TYPES_FOR_EXPORT }
      it { is_expected.to be_a(Array) }
      it { is_expected.to_not include('faculty_letter_of_recommendation') }
    end

    context '#attachments' do
      subject { converter.attachments }
      before do
        expect(repository).to receive(:work_attachments).with(
          work: work, predicate_name: described_class::ATTACHMENT_TYPES_FOR_EXPORT
        ).and_return(:returned_value)
      end
      it { is_expected.to be_a(Array) }
    end

    context '#creator_names' do
      subject { converter.creator_names }
      before do
        expect(repository).to(
          receive(:scope_users_for_entity_and_roles).with(
            entity: work, roles: Models::Role::CREATING_USER
          ).and_return(double(name: 'Bob'))
        )
      end
      it { is_expected.to be_a(Array) }
    end
  end
end
