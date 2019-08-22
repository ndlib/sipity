require 'devise/strategies/cas_authenticatable_with_service_agreement'

# Every application needs users. Right? This is that class.
class User < ActiveRecord::Base
  devise :omniauthable, omniauth_providers: [:oktaoauth]

  has_many :group_memberships, dependent: :destroy, class_name: 'Sipity::Models::GroupMembership'
  has_one :processing_actor, as: :proxy_for, class_name: 'Sipity::Models::Processing::Actor'
  has_many :event_logs, class_name: 'Sipity::Models::EventLog'

  # I'm using a callback because Devise CAS authentication is creating the
  # record.
  before_save :set_notre_dame_specific_email, if: :new_record?

  class_attribute :on_user_create_service
  self.on_user_create_service = Rails.application.config.default_on_user_create_service

  def self.from_omniauth(auth)
    # TODO: I would prefer NetID, but I do not yet have that exposed
    username = auth.info.email.sub("@nd.edu", "")
    find_or_create_by_auth(username: username, provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.name ||= auth.info.name
    end
  end

  def self.find_or_create_by_auth(username:, provider:, uid:)
    user =
      find_by(username: username, provider: nil, uid: nil) ||
      find_by(provider: provider, uid: uid) ||
      new(username: username, provider: provider, uid: uid)
    user.provider = provider
    user.uid = uid
    user.username = username
    yield(user) if block_given?
    user.save!
    user
  end

  after_commit :call_on_create_user_service, on: :create
  # Because of the unique constraint on User#email, when we receive an empty
  # email for user (e.g. the user form that was filled out had blank spaces for
  # the given email), blank that out.
  def email=(value)
    if value.present?
      super(value)
    else
      super(nil)
    end
  end

  def to_s
    # HACK: Name is better, but in some cases this may not be assigned.
    # So defer to username. See issues#436
    name || username
  end

  private

  def set_notre_dame_specific_email
    self.email ||= "#{username}@nd.edu"
  end

  def call_on_create_user_service
    on_user_create_service.call(self)
  end
end
