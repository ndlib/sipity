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
    end
  end
end
