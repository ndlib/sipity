require "rails_helper"

describe User do

  subject { User.new(email: 'user@example.com', name: "Hello Somebody") }

  it { is_expected.to respond_to(:email) }

  it { expect(User.create!(username: 'bogus', email: '')).to callback(:call_on_create_user_service).after(:commit) }

  it 'will allow multiple users to have a "" email' do
    User.create!(username: 'one', email: '')
    expect { User.create!(username: 'two', email: '') }.to_not raise_error
  end

  its(:to_s) { is_expected.to eq subject.name }

  describe '.from_omniauth' do
    let(:raw_info) { double("raw_info", netid: 'hello', email: 'hello@nd.edu', name: "Hello World") }
    let(:auth) { double("auth", extra: double(raw_info: raw_info), provider: "a_provider", uid: "a_uid") }
    describe "when provided user exists but has not used omniauth" do
      let(:user) { User.new(email: raw_info.email, username: raw_info.netid, name: raw_info.name) }
      before do
        user.save!
      end
      it "will not create a new record and instead update the existing record" do
        authenticated_user = described_class.from_omniauth(auth)
        expect(authenticated_user).to be_persisted
        expect(authenticated_user).to eq(user)
        user.reload
        expect(user.provider).to eq(auth.provider)
        expect(user.uid).to eq(auth.uid)
      end
    end
    describe "when provided user does not exist" do
      it 'will create a new user' do
        authenticated_user = described_class.from_omniauth(auth)
        expect(authenticated_user).to be_persisted
      end
    end
    describe "when provided user exists and has used omniauth" do
      let(:user) { User.new(email: raw_info.email, username: raw_info.netid, name: raw_info.name, uid: auth.uid, provider: auth.provider) }
      before do
        user.save!
      end
      it "will return the previous user" do
        authenticated_user = described_class.from_omniauth(auth)
        expect(authenticated_user).to be_persisted
      end
    end
  end

  describe "when user agreed_to_terms_of_service" do
    subject { User.new(email: 'user@example.com', name: "Hello Somebody", agreed_to_terms_of_service: agreed_to_terms_of_service) }
    let(:agreed_to_terms_of_service) { true }
    its(:active_for_authentication?) { is_expected.to eq(true) }
    its(:unauthenticated_message) { is_expected.to eq(:invalid) }
  end
  describe "when user HAS NOT agreed_to_terms_of_service" do
    subject { User.new(email: 'user@example.com', name: "Hello Somebody", agreed_to_terms_of_service: agreed_to_terms_of_service) }
    let(:agreed_to_terms_of_service) { false }
    its(:active_for_authentication?) { is_expected.to eq(:no_tos_agreement) }
    its(:unauthenticated_message) { is_expected.to eq(:no_tos_agreement) }
  end
end
