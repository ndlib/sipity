require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe EmailNotificationDecorator do
      let(:entity) { Models::Work.new(title: 'Hello World', id: 123) }
      subject { EmailNotificationDecorator.new(entity) }

      it { should respond_to(:netid) }
      it { should respond_to(:creator) }
      it { should respond_to(:director) }
      it { should respond_to(:document_type) }
      it { should respond_to(:approval_date) }
      it { should respond_to(:approved_by_directors) }
      it { should respond_to(:review_link_for_grad_school) }
      it { should respond_to(:review_link_for_advisor) }
      it { should respond_to(:permission_for_third_party_materials) }
      it { should respond_to(:comments) }
      it { should respond_to(:url) }
      it { should respond_to(:curate_link) }
      it { should respond_to(:degree) }
      it { should respond_to(:graduate_programs) }
      it { should respond_to(:release_date) }
      it { should respond_to(:access_rights) }
      it { should respond_to(:will_be_released_to_the_public?) }

    end
  end
end
