require 'spec_helper'
module Sipity
  module Services
    RSpec.describe ApplyAccessPoliciesTo do
      let(:user) { User.new }
      let(:work) { Models::Work.new(id: 1) }
      let(:attachment) { Models::Attachment.new(id: 2) }
      let(:access_policies) { {} }

      subject { described_class.new(work: work, user: user, access_policies: access_policies) }

      it 'exposes .call as a convenience method' do
        expect_any_instance_of(described_class).to receive(:call)
        described_class.call(work: work, user: user, access_policies: access_policies)
      end

      it 'will not allow specifying policies for objects not part of the existing work'

      let(:access_policies) do
        { entity_id: 1, entity_type: Sipity::Models::Work, access_right_code: Models::AccessRight::OPEN_ACCESS, release_date: '' }
      end
      it 'create a new AccessRight' do
        expect { subject.call }.to change { Models::AccessRight.count }.by(1)
      end
      it 'will obliterate the previous AccessRights' do
        subject.call
        expect { subject.call }.to_not change { Models::AccessRight.count }
      end
    end
  end
end
