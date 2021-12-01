class PersonalAccessToken < ApplicationRecord
  audited :except => [:token], :associated_with => :user
  include Authorizable
  include Expirable
  extend Foreman::TelemetryHelper

  belongs_to :user

  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :on => :name
  scoped_search :on => :user_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

  validates_lengths_from_database

  validates :token, :user_id, :token, presence: true
  validates :name, presence: true, uniqueness: {scope: :user_id}

  scope :active, -> { where(revoked: false).where("expires_at >= ? OR expires_at IS NULL", Time.current.utc) }
  scope :inactive, -> { where(revoked: true).or(where("expires_at < ?", Time.current.utc)) }

  attr_accessor :token_value

  def self.authenticate_user(user, token)
    token = active.find_by(user: user, token: hash_token(user, token, :bcrypt)) ||
      active.find_by(user: user, token: hash_token(user, token, :sha1))
    return false unless token

    User.as_anonymous_admin do
      token.update(last_used_at: Time.current.utc)
    end

    true
  end

  # static salt based on user id because input is already good enough (sha1 string)
  def self.token_salt(user, type = :bcrypt)
    hasher = Foreman::PasswordHash.new(type)
    hasher.calculate_salt(user.id, Setting[:bcrypt_cost])
  end

  def self.hash_token(user, token, type = :bcrypt)
    telemetry_duration_histogram(:login_pwhash_duration, :ms, algorithm: type) do
      hasher = Foreman::PasswordHash.new(type)
      hasher.hash_secret(token, token_salt(user, type))
    end
  end

  def generate_token(type = :bcrypt)
    self.token_value = SecureRandom.urlsafe_base64(nil, false)
    self.token = self.class.hash_token(user, token_value, type)
    token_value
  end

  def check_permissions_after_save
    return true if user == User.current
    super
  end

  def revoke!
    update!(revoked: true)
  end

  def revoked?
    !!revoked
  end

  def expires?
    expires_at.present?
  end

  def active?
    !revoked? && !expired?
  end

  def used?
    last_used_at.present?
  end
end
