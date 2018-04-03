class SshKey < ApplicationRecord
  audited :associated_with => :user
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName

  belongs_to :user
  before_validation :generate_fingerprint
  before_validation :calculate_length

  scoped_search :on => :name
  scoped_search :on => :user_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

  validates_lengths_from_database

  validates :name, :user_id,
    :presence => true

  validates :key,
    :presence => true,
    :ssh_key => true,
    :format => { with: /\A(ssh|ecdsa)-.*\Z/, message: N_('must be in OpenSSH public key format') }

  validates :key,
    :format => { :without => /\n|\r/, :message => N_('should be a single line') }

  validates :fingerprint,
    :uniqueness => { :scope => :user_id },
    :presence => { :message => N_('could not be generated') }

  validates :length,
    :presence => { :message => N_('could not be calculated') }

  delegate :login, to: :user, prefix: true

  class Jail < ::Safemode::Jail
    allow :name, :user, :key, :to_export, :fingerprint, :length, :ssh_key, :type, :comment
  end

  def to_export
    type, base64 = self.key.split
    [type, base64, comment].join(' ')
  end

  def to_export_hash
    {
      'type' => type,
      'key' => ssh_key,
      'comment' => comment
    }
  end

  def type
    key.split(' ').first
  end

  def ssh_key
    key.split(' ')[1]
  end

  def comment
    "#{user_login}@#{URI.parse(Setting[:foreman_url]).host}"
  end

  def self.title_name
    'login'.freeze
  end

  private

  def generate_fingerprint
    self.fingerprint = nil
    return unless self.key.present?
    self.fingerprint = SSHKey.fingerprint(self.key)
    true
  rescue SSHKey::PublicKeyError => exception
    Foreman::Logging.exception("Could not calculate SSH key fingerprint", exception)
    nil
  end

  def calculate_length
    self.length = nil
    return unless self.key.present?
    self.length = SSHKey.ssh_public_key_bits(self.key)
    true
  rescue SSHKey::PublicKeyError => exception
    Foreman::Logging.exception("Could not calculate SSH key length", exception)
    nil
  end
end
