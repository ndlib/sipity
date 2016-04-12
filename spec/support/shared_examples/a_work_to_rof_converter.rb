module Sipity
  RSpec.shared_examples 'a work to rof converter' do |parameters|
    let(:work) do
      Models::Work.new(id: 'abcd-ef', access_right: access_right, created_at: Time.zone.today)
    end
    let(:access_right) { Models::AccessRight.new(access_right_code: Models::AccessRight::OPEN_ACCESS) }
    let(:collaborator) { Models::Collaborator.new(role: Models::Collaborator::ADVISING_FACULTY_ROLE, name: 'Alexander Hamilton') }
    let(:repository) { QueryRepositoryInterface.new }
    let(:converter) { described_class.new(work: work, repository: repository) }

    context '#default_repository' do
      subject { converter.send(:default_repository) }
      it { is_expected.to respond_to :work_attachments }
    end

    context '#to_rof' do
      subject { converter.to_rof }
      it { is_expected.to be_a(Array) }
    end

    context '#edit_groups' do
      subject { converter.to_rof }
      it { is_expected.to be_a(Array) }
    end

    context '#to_hash' do
      subject { converter.to_hash }
      it { is_expected.to be_a(Hash) }
    end

    context '#rof_type' do
      subject { converter.rof_type }
      it { is_expected.to be_a(String) }
    end

    context '#metadata' do
      subject { converter.metadata }
      it { is_expected.to be_a(Hash) }
    end

    context '#attachments' do
      subject { converter.attachments }
      before { allow(repository).to receive(:work_attachments).and_call_original }
      let(:attachment_predicate_name) { parameters.fetch(:attachment_predicate_name) }
      it "should retrieve attachments for predicate_name(s) #{parameters.fetch(:attachment_predicate_name).inspect}" do
        expect(repository).to receive(:work_attachments).with(
          work: work, predicate_name: attachment_predicate_name
        ).and_return(:returned_value)
        subject
      end
      it { is_expected.to be_a(Array) }
    end

    context '#attachments' do
      subject { converter.attachments }
      it { is_expected.to be_a(Array) }
    end

    context '#rels_ext' do
      subject { converter.rels_ext }
      it { is_expected.to be_a(Hash) }
    end

    context '#properties_meta' do
      subject { converter.properties_meta }
      it { is_expected.to be_a(Hash) }
    end

    context '#properties' do
      subject { converter.properties }
      it { is_expected.to be_a(String) }
    end

    context '#access_rights' do
      subject { converter.access_rights }
      it { is_expected.to be_a(Hash) }
    end

    context '#af_model' do
      let(:given_af_model) { parameters.fetch(:af_model) }
      subject { converter.af_model }
      it { is_expected.to eq(given_af_model) }
    end
  end
end
