require 'rails_helper'

module Sipity
  module Models
    RSpec.describe Group, type: :model do
      subject { described_class.new }
      its(:valid?) { should be false }

      it { should delegate_method(:to_s).to(:name) }

      it 'will have a Group.all_registered_users' do
        expect(described_class.all_registered_users).to be_persisted
      end
    end
  end
end
