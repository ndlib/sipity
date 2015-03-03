module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe AccessPolicyForm do
        let(:user) { double('User') }
        let(:work) { Models::Work.new(id: 1) }
        let(:attachment) { Models::Attachment.new(id: 2) }
        let(:repository) { CommandRepositoryInterface.new }
        subject { described_class.new(work: work, repository: repository) }

        before do
          allow(repository).to receive(:accessible_objects).with(work: work).and_return([work, attachment])
        end

        it { should respond_to :accessible_objects_attributes= }

        it 'will expose accessible_objects' do
          expect(subject.accessible_objects.size).to eq(2)
        end

        it 'will validate the presence of accessible_objects_attributes' do
          subject = described_class.new(work: work, repository: repository, accessible_objects_attributes: {})
          subject.valid?
          expect(subject.errors[:base]).to be_present
        end

        it 'will validate each of the given attributes' do
          invalid_attributes = { "0" => { id: work.to_param, access_right_code: 'chici chici parm parm' } }
          subject = described_class.new(work: work, repository: repository, accessible_objects_attributes: invalid_attributes)
          subject.valid?
          expect(subject.errors[:accessible_objects_attributes]).to be_present
        end

        context '#submit' do
          it 'will capture accessible_objects_attributes' do
            attributes = {
              "0" => { "id" => work.to_param, "access_right_code" => 'open_access', "release_date" => "" },
              "1" => { "id" => attachment.to_param, "access_right_code" => 'embargo_then_open_access', "release_date" => "2032-12-01" }
            }
            subject = described_class.new(work: work, repository: repository, accessible_objects_attributes: attributes)
            expect(repository).to receive(:apply_access_policies_to).with(
              work: work, user: user, access_policies:
              [
                {
                  entity_id: work.to_param,
                  entity_type: Sipity::Models::Work,
                  access_right_code: 'open_access',
                  release_date: nil,
                }, {
                  entity_id: attachment.to_param,
                  entity_type: Sipity::Models::Attachment,
                  access_right_code: 'embargo_then_open_access',
                  release_date: Date.new(2032,12,01)
                }
              ]
            )
            subject.submit(requested_by: user)
          end
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
