require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe EmailNotificationDecorator do
      let(:repository) { QueryRepositoryInterface.new }
      let(:entity) { Models::Work.new(id: '123', work_type: 'doctoral_dissertation', title: 'A title') }

      subject { described_class.new(entity, repository: repository) }

      it { should respond_to(:netid) }
      it { should respond_to(:creators) }
      it { should respond_to(:creator_names) }
      it { should respond_to(:creator_usernames) }
      it { should respond_to(:director) }
      it { should respond_to(:document_type) }
      it { should respond_to(:approval_date) }
      it { should respond_to(:approved_by_directors) }
      it { should respond_to(:review_link) }
      it { should respond_to(:permission_for_third_party_materials) }
      it { should respond_to(:comments) }
      it { should respond_to(:curate_link) }
      it { should respond_to(:review_link) }
      it { should respond_to(:degree) }
      it { should respond_to(:graduate_programs) }
      it { should respond_to(:release_date) }
      it { should respond_to(:access_rights) }
      it { should respond_to(:will_be_released_to_the_public?) }
      it 'shares .object_class with Models::Work' do
        expect(EmailNotificationDecorator.object_class).to eq(Models::Work)
      end

      its(:document_type) { should eq(entity.work_type.humanize) }

      its(:title) { should eq entity.title }

      it 'will have a #work_show_path' do
        expect(subject.work_show_path).to be_a(String)
      end

      context 'with "open_access" rights' do
        before do
          allow(repository).to receive(:work_access_right_codes).and_return(answer)
        end
        Given(:answer) { 'open_access' }
        Then { subject.access_rights == answer.titleize }
      end

      context 'returns only the names' do
        before do
          allow(repository).to receive(:scope_users_for_entity_and_roles).and_return(creating_users)
        end
        let(:creating_users) {  [double(name: 'John', username: 'john'), double(name: 'A name', username: 'netid')] }
        it 'will have #creators' do
          expect(subject.creators).to be_a(Array)
          expect(subject.creator_names).to eq('John and A name')
          expect(subject.creator_usernames).to eq('john and netid')
        end
      end
    end
  end
end
