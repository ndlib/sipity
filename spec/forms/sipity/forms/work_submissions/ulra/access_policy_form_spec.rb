require 'spec_helper'
require 'sipity/forms/work_submissions/ulra/access_policy_form'
require 'sipity/models/work'
require 'support/sipity/command_repository_interface'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe AccessPolicyForm do
          let(:user) { double('User') }
          let(:work) { Models::Work.new(id: 1) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:keywords) { { work: work, requested_by: user, repository: repository, attributes: attributes } }
          subject { described_class.new(keywords) }

          its(:representative_attachment_predicate_name) { should eq(Forms::WorkSubmissions::Ulra::AttachForm.attachment_predicate_name) }

          it 'will leverage the representative_attachment_predicate_name for the #available_representative_attachments' do
            expect(repository).to receive(:work_attachments).with(
              work: work, predicate_name: subject.representative_attachment_predicate_name
            ).and_return([1, 2, 3])
            expect(subject.available_representative_attachments).to eq([1, 2, 3])
          end
        end
      end
    end
  end
end
