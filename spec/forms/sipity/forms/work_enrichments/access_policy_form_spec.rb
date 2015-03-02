module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe AccessPolicyForm do
        let(:work) { Models::Work.new(id: 1) }
        let(:attachment) { Models::Attachment.new(id: 2) }
        let(:repository) { CommandRepositoryInterface.new }
        subject { described_class.new(work: work, repository: repository) }

        it { should respond_to :accessible_objects_attributes= }

        it 'will expose accessible_objects' do
          expect(repository).to receive(:accessible_objects).with(work: work).and_return([work, attachment])
          subject.accessible_objects
        end
      end

      RSpec.describe AccessPolicyForm::AccessibleObjectFromInput do
        let(:attributes) { {} }
        let(:persisted_object) { double('Persisted Object') }
        subject { described_class.new(persisted_object, attributes) }

        its(:persisted?) { should be_truthy }

        it 'will parse the input date' do

        end

        it 'will be invalid if no access_right_code is given' do
          subject.valid?
          expect(subject.errors[:access_right_code]).to be_present
        end

        it 'will be invalid if no release_date is given for "embargo_then_open_access"' do
          subject = described_class.new(persisted_object, access_right_code: 'embargo_then_open_access')
          subject.valid?
          expect(subject.errors[:release_date]).to be_present
        end

        it 'will be invalid if an incorrect access code is given' do
          subject = described_class.new(persisted_object, access_right_code: 'chocolate bunny')
          subject.valid?
          expect(subject.errors[:access_right_code]).to be_present
        end
      end
    end
  end
end
