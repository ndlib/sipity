require "rails_helper"

module Sipity
  module Controllers
    module WorkAreas
      RSpec.describe WorkPresenter do
        let(:creating_user) { User.new(email: 'somebody@tolove.com', name: 'Some Body') }
        let(:advising_user) { User.new(email: 'lastbathroom@aol.com', name: 'Last Bathroom') }
        let(:repository) { QueryRepositoryInterface.new }
        let(:context) { PresenterHelper::ContextWithForm.new(repository: repository) }
        let(:program_names) { ["name one"] }
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
          allow(repository).to(
            receive(:work_attribute_values_for).
              with(work: work, key: "program_name", cardinality: :many).and_return(program_names)
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

        describe '#author_name' do
          let(:author_name_from_repository) { "author 1" }
          let(:author_name_from_work) { "author from work" }
          before do
            allow(repository).to(
              receive(:work_attribute_values_for).
                with(work: work, key: 'author_name', cardinality: 1).and_return(author_name_from_repository)
            )
          end

          it 'first checks the work' do
            allow(work).to receive(:author_name).and_return(author_name_from_work)
            allow(work).to receive(:respond_to?).with(:author_name).and_return(true)
            expect(subject.author_name).to eq(author_name_from_work)
          end

          it 'fallsback to the additional attributes' do
            allow(work).to receive(:respond_to?).with(:author_name).and_return(false)
            expect(subject.author_name).to eq(author_name_from_repository)
          end
        end

        describe '#etd_submission_date' do
          let(:etd_submission_date_from_repository) { "2021-01-01" }
          let(:etd_submission_date_from_work) { "2020-02-02" }
          before do
            allow(repository).to(
              receive(:work_attribute_values_for).
                with(work: work, key: 'etd_submission_date', cardinality: 1).and_return(etd_submission_date_from_repository)
            )
          end

          it 'first checks the work' do
            allow(work).to receive(:etd_submission_date).and_return(etd_submission_date_from_work)
            allow(work).to receive(:respond_to?).with(:etd_submission_date).and_return(true)
            expect(subject.etd_submission_date).to eq(etd_submission_date_from_work)
          end

          it 'fallsback to the additional attributes' do
            allow(work).to receive(:respond_to?).with(:etd_submission_date).and_return(false)
            expect(subject.etd_submission_date).to eq(etd_submission_date_from_repository)
          end
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
