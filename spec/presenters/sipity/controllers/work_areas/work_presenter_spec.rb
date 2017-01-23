require "rails_helper"

module Sipity
  module Controllers
    module WorkAreas
      RSpec.describe WorkPresenter do
        let(:creating_user) { User.new(email: 'somebody@tolove.com', name: 'Some Body') }
        let(:advising_user) { User.new(email: 'lastbathroom@aol.com', name: 'Last Bathroom') }
        let(:repository) { QueryRepositoryInterface.new }
        let(:context) { PresenterHelper::ContextWithForm.new(repository: repository) }
        let(:work) do
          double(
            'Work',
            title: 'hello',
            work_type: 'doctoral_dissertation',
            processing_state: 'new',
            created_at: Time.zone.today,
            submission_window: Models::SubmissionWindow.new(slug: '2017')
          )
        end

        before do
          allow(repository).to(
            receive(:scope_users_for_entity_and_roles).
              with(entity: work, roles: Models::Role::CREATING_USER).and_return(creating_user)
          )
          allow(repository).to(
            receive(:scope_users_for_entity_and_roles).
              with(entity: work, roles: Models::Role::ADVISING).and_return(advising_user)
          )
        end

        subject { described_class.new(context, work: work) }

        its(:title) { is_expected.to be_html_safe }
        its(:processing_state) { is_expected.to eq('New') }
        its(:date_created) { is_expected.to be_a(String) }
        its(:creator_names_to_sentence) { is_expected.to be_a(String) }
        its(:creator_names_as_email_links) { is_expected.to be_html_safe }
        its(:program_names_to_sentence) { is_expected.to be_a(String) }
        its(:work_type) { is_expected.to eq('Doctoral dissertation') }
        it { is_expected.to delegate_method(:submission_window).to(:work) }

        it 'will delegate path to PowerConverter' do
          expect(PowerConverter).to receive(:convert).with(work, to: :access_path).and_return('/the/path')
          expect(subject.path).to eq('/the/path')
        end

        describe '#advisor_names_as_email_links' do
          subject { described_class.new(context, work: work).advisor_names_as_email_links }
          it { is_expected.to be_html_safe }
        end

        describe '#creator_names_as_email_links' do
          subject { described_class.new(context, work: work).creator_names_as_email_links }
          let(:a_user) { User.new(email: 'somebody@tolove.com') }
          it { is_expected.to be_html_safe }
        end
      end
    end
  end
end
