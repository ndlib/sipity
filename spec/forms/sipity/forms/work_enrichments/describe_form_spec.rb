require 'spec_helper'

module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe DescribeForm do
        let(:work) { Models::Work.new(id: '1234') }
        let(:repository) { CommandRepositoryInterface.new }
        subject { described_class.new(work: work, repository: repository) }

        before do
          allow(repository).to receive(:work_attribute_values_for).and_return([])
        end

        its(:enrichment_type) { should eq('describe') }
        its(:policy_enforcer) { should eq Policies::Processing::WorkProcessingPolicy }

        it { should respond_to :work }
        it { should respond_to :title }
        it { should respond_to :abstract }
        it { should respond_to :discipline }
        it { should respond_to :alternate_title }

        it 'will require a title' do
          subject.valid?
          expect(subject.errors[:title]).to be_present
        end

        it 'will require a abstract' do
          subject.valid?
          expect(subject.errors[:abstract]).to be_present
        end

        it 'will require a work' do
          subject = described_class.new(work: nil)
          subject.valid?
          expect(subject.errors[:work]).to_not be_empty
        end

        context '#abstract' do
          let(:abstract) { ['Hello Dolly'] }
          let(:discipline) { ['Computer Science'] }
          let(:title) { 'My Work title' }
          subject { described_class.new(work: work, repository: repository) }
          it 'will return the abstract of the work' do
            expect(repository).to receive(:work_attribute_values_for).
              with(work: work, key: 'alternate_title').and_return("")
            expect(repository).to receive(:work_attribute_values_for).
              with(work: work, key: 'abstract').and_return(abstract)
            expect(repository).to receive(:work_attribute_values_for).
              with(work: work, key: 'discipline').and_return(discipline)
            expect(subject.abstract).to eq 'Hello Dolly'
            expect(subject.discipline).to eq 'Computer Science'
            expect(subject.alternate_title).to eq ''
          end

          it 'will update and return title of the work' do
            expect(work).to receive(:title).and_return(title)
            expect(subject.title).to eq title
          end
        end

        it 'will require a discipline' do
          subject.valid?
          expect(subject.errors[:discipline]).to be_present
        end

        context '#submit' do
          let(:user) { double('User') }
          context 'with invalid data' do
            before do
              expect(subject).to receive(:valid?).and_return(false)
            end
            it 'will return false if not valid' do
              expect(subject.submit(requested_by: user))
            end
            it 'will not create create any additional attributes entries' do
              expect { subject.submit(requested_by: user) }.
                to_not change { Models::AdditionalAttribute.count }
            end
          end

          context 'with valid data' do
            subject { described_class.new(work: work, abstract: 'Hello Dolly', repository: repository) }
            before do
              expect(subject).to receive(:valid?).and_return(true)
            end

            it 'will return the work' do
              returned_value = subject.submit(requested_by: user)
              expect(returned_value).to eq(work)
            end

            it "will transition the work's corresponding enrichment todo item to :done" do
              expect(repository).to receive(:register_action_taken_on_entity).and_call_original
              subject.submit(requested_by: user)
            end

            it 'will update title of the work' do
              expect(repository).to receive(:update_work_title!).exactly(1).and_call_original
              subject.submit(requested_by: user)
            end

            it 'will add additional attributes entries' do
              expect(repository).to receive(:update_work_attribute_values!).exactly(3).and_call_original
              subject.submit(requested_by: user)
            end

            it 'will record the event' do
              expect(repository).to receive(:log_event!).and_call_original
              subject.submit(requested_by: user)
            end
          end
        end
      end
    end
  end
end
