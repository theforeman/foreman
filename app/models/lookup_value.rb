class LookupValue < ApplicationRecord
  audited :associated_with => :lookup_key
  extend FriendlyId
  friendly_id :match
  include Authorizable
  include HiddenValue
  include KeyValueValidation

  validates_lengths_from_database
  delegate :hidden_value?, :editable_by_user?, :to => :lookup_key, :allow_nil => true

  belongs_to :lookup_key
  delegate :key, :to => :lookup_key
  before_validation :sanitize_match

  validate :ensure_match_uniqueness
  validates :match, :presence => true, :uniqueness => {:scope => :lookup_key_id}, :format => LookupKey::VALUE_REGEX
  validate :ensure_fqdn_exists, :ensure_hostgroup_exists, :ensure_matcher_exists
  validate :validate_value, :unless => proc { |p| p.omit }

  attr_accessor :host_or_hostgroup

  serialize :value
  attr_name :match

  scope :default, -> { where(:match => "default").limit(1) }

  scoped_search :on => :value, :complete_value => true, :default_order => true
  scoped_search :on => :match, :complete_value => true
  scoped_search :relation => :lookup_key, :on => :key, :rename => :lookup_key, :complete_value => true

  # Lookup values are currently not authorized granularly,
  # they should use permissions from their keys (puppet or variable)
  def check_permissions_after_save
    true
  end

  def value=(val)
    if val.is_a?(HashWithIndifferentAccess)
      super(val.deep_to_hash)
    else
      super
    end
  end

  def name
    match
  end

  def value_before_type_cast
    return self[:value] if errors[:value].present?
    return value if lookup_key.nil? || value.contains_erb?
    LookupKey.format_value_before_type_cast(value, lookup_key.key_type)
  end

  def validate_value
    validate_and_cast_value(lookup_key)
    Foreman::Parameters::Validator.new(self,
      :type => lookup_key.validator_type,
      :validate_with => lookup_key.validator_rule,
      :getter => :value).validate!
  end

  def path
    match.split(LookupKey::KEY_DELM).map { |s| s.split(LookupKey::EQ_DELM).first }.join(LookupKey::KEY_DELM)
  end

  private

  # TODO check multi match with matchers that have space (hostgroup = web servers,environment = production)
  def sanitize_match
    return true unless match.present?
    self.match = match.split(LookupKey::KEY_DELM).map do |m|
      split_match = m.split(LookupKey::EQ_DELM)
      matcher_attribute = split_match.first.downcase.strip
      matcher_value = (split_match.count > 1) ? split_match.last.strip : ""
      [matcher_attribute, matcher_value].join(LookupKey::EQ_DELM)
    end.join(LookupKey::KEY_DELM)
  end

  def ensure_fqdn_exists
    md = ensure_matcher(/fqdn=(.*)/)
    return md if md == true || md == false
    fqdn = md[1].split(LookupKey::KEY_DELM)[0]
    return true if host_with_fqdn_exists?(fqdn) || host_or_hostgroup.try(:new_record?) ||
        (host_or_hostgroup.present? && host_or_hostgroup.type_changed? && host_or_hostgroup.type == "Host::Managed")
    errors.add(:match, _("%{match} does not match an existing host") % { :match => "fqdn=#{fqdn}" })

    false
  end

  def ensure_hostgroup_exists
    md = ensure_matcher(/hostgroup=(.*)/)
    return md if md == true || md == false
    hostgroup = md[1].split(LookupKey::KEY_DELM)[0]
    return true if Hostgroup.unscoped.find_by_name(hostgroup) || Hostgroup.unscoped.find_by_title(hostgroup) || host_or_hostgroup.try(:new_record?)
    errors.add(:match, _("%{match} does not match an existing host group") % { :match => "hostgroup=#{hostgroup}" })

    false
  end

  def ensure_matcher(match_type)
    return false if match.blank?
    matcher = match.match(match_type)
    return true unless matcher
    matcher
  end

  def ensure_matcher_exists
    return false if match.blank?
    key_elements = []
    match.split(LookupKey::KEY_DELM).each do |m|
      key_elements << m.split(LookupKey::EQ_DELM).first
    end

    unless lookup_key.path_elements.include?(key_elements)
      errors.add(:match, _("%{key} does not exist in order field") % { :key => key_elements.join(',') })
    end
  end

  # needs to be validated manualy as at validation time, siblings might not be saved
  def ensure_match_uniqueness
    return if lookup_key.nil?
    errors.add(:match, :taken) if lookup_key.lookup_values.any? { |sibling| sibling != self && sibling.match == match }
  end

  def skip_strip_attrs
    ['value']
  end

  def host_with_fqdn_exists?(fqdn)
    Host.unscoped.left_joins(:primary_interface).where(nics: {name: fqdn}).any?
  end
end
