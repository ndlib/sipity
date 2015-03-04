require 'spec_helper'
module Sipity
  module Mailers
    describe EmailNotifier do
      before do
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []
      end
      after do
        ActionMailer::Base.deliveries.clear
      end
      context '#confirmation_of_entity_submitted_for_review' do
        let(:entity) { Models::Work.new(id: '123') }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.confirmation_of_entity_submitted_for_review(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#request_revision_from_creator' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.request_revision_from_creator(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#entity_ready_for_cataloging' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.entity_ready_for_cataloging(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#request_revision_from_creator' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.request_revision_from_creator(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#entity_ready_for_review' do
        let(:entity) { double('Hello') }
        let(:decorated) { double(creator: 'A name', review_link: "link to work show", document_type: "A document_type") }
        let(:decorator) { double(new: decorated) }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          expect(entity).to receive(:work)
          described_class.entity_ready_for_review(entity: entity, to: to, decorator: decorator).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#entity_ready_for_cataloging' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.entity_ready_for_cataloging(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#confirmation_of_entity_ingested' do
        let(:repository) { QueryRepositoryInterface.new }
        let(:entity) { double('Hello') }
        let(:to) { 'test@example.com' }
        let(:decorated) do
          double(creator: 'A name', created_at: "A Date", document_type: "A document_type",
                 title: 'A title', netid: 'A net id', graduate_programs: 'Program Name', curate_link: 'link')
        end
        let(:decorator) { double(new: decorated) }

        it 'should send an email' do
          described_class.confirmation_of_entity_ingested(entity: entity, to: to, decorator: decorator).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#advisor_requests_change' do
        let(:entity) { double('Hello') }
        let(:decorated) { double(name_of_commentor: 'A name', comment: "A comment", document_type: "A document_type") }
        let(:decorator) { double(new: decorated) }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.advisor_requests_change(entity: entity, to: to, decorator: decorator).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#grad_school_requests_change' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.grad_school_requests_change(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#confirmation_of_grad_school_signoff' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.confirmation_of_grad_school_signoff(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#all_advisors_have_signed_off' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.all_advisors_have_signed_off(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#advisor_signoff_but_still_more_to_go' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.advisor_signoff_but_still_more_to_go(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
    end
  end
end
