require 'spec_helper'

module Sipity
  module Models
    RSpec.describe AccessRightFacade do
      let(:object) { Models::Work.new(id: 123) }
      let(:access_right) { Models::AccessRight.new(access_right_code: 'embargo_then_open_access', release_date: Date.today) }
      subject { described_class.new(object) }

      before { allow(Models::AccessRight).to receive(:find_or_initialize_by).and_return(access_right) }

      its(:id) { should eq(object.id) }
      its(:persisted?) { should eq(object.persisted?) }
      its(:to_s) { should eq(object.to_s) }
      its(:entity_id) { should eq(subject.id) }
      its(:to_param) { should eq(object.to_param) }
      its(:entity_type) { should eq(Sipity::Models::Work) }
      its(:access_right_code) { should eq(access_right.access_right_code) }
      its(:release_date) { should eq(access_right.release_date) }
    end
  end
end
