require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe CreateSipForm do
      subject { described_class.new }

      its(:policy_enforcer) { should eq Policies::SipPolicy }

      it 'will have a #possible_work_publication_strategies' do
        expect(subject.possible_work_publication_strategies).to be_a(Hash)
      end

      it 'will have a model name like Sip' do
        expect(described_class.model_name).to be_a(ActiveModel::Name)
      end

      context 'validations for' do
        context '#title' do
          it 'must be present' do
            subject.valid?
            expect(subject.errors[:title]).to be_present
          end
        end
        context '#work_publication_strategy' do
          it 'must be present' do
            subject.valid?
            expect(subject.errors[:work_publication_strategy]).to be_present
          end
          it 'must be from the approved list' do
            subject.work_publication_strategy = '__missing__'
            subject.valid?
            expect(subject.errors[:work_publication_strategy]).to be_present
          end
        end
        context '#publication_date' do
          it 'must be present when it was :already_published' do
            subject.work_publication_strategy = 'already_published'
            subject.valid?
            expect(subject.errors[:publication_date]).to be_present
          end
          it 'need not be present otherwise' do
            subject.valid?
            expect(subject.errors[:publication_date]).to_not be_present
          end
        end
      end
    end
  end
end
