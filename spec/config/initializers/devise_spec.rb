require 'rails_helper'

RSpec.describe 'config/initializers/devise.rb' do
  context '.mappings' do
    subject { Devise.mappings }
    it 'will have a :user mapping' do
      expect(subject[:user].to).to eq(User)
    end
    it 'will have a :user_profile_management mapping' do
      expect(subject[:user_for_profile_management].to).to eq(User)
    end
  end

  context '.warden' do
    subject { Devise.warden_config.fetch(:default_strategies) }
    it 'will have :user_for_profile_management strategies' do
      expect(subject[:user_for_profile_management]).to eq([:authenticated_but_tos_not_required])
    end
  end
end
