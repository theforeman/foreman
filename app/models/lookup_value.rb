class LookupValue < ApplicationRecord
  include Authorizable
  include PuppetLookupValueExtensions
  include HiddenValue

  validates_lengths_from_database
  audited :associated_with => :lookup_key
  delegate :hidden_value?, :editable_by_user?, :to => :lookup_key, :allow_nil => true

  belongs_to :lookup_key
  validates :match, :presence => true, :uniqueness => {:scope => :lookup_key_id}, :format => LookupKey::VALUE_REGEX
  delegate :key, :to => :lookup_key
  before_validation :sanitize_match

  validate :ensure_fqdn_exists, :ensure_hostgroup_exists, :ensure_matcher_exists
  validate :validate_value, :unless => Proc.new{|p| p.omit }

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
    return read_attribute(:value) if errors[:value].present?
    return self.value if lookup_key.nil? || value.contains_erb?
    lookup_key.value_before_type_cast self.value
  end

  def validate_value
    validate_and_cast_value
    Foreman::Parameters::Validator.new(self,
      :type => lookup_key.validator_type,
      :validate_with => lookup_key.validator_rule,
      :getter => :value).validate!
  end

  def path
    match.split(LookupKey::KEY_DELM).map{|s| s.split(LookupKey::EQ_DELM).first}.join(LookupKey::KEY_DELM)
  end

  private

  #TODO check multi match with matchers that have space (hostgroup = web servers,environment = production)
  def sanitize_match
    self.match = match.split(LookupKey::KEY_DELM).map {|s| s.split(LookupKey::EQ_DELM).map(&:strip).join(LookupKey::EQ_DELM)}.join(LookupKey::KEY_DELM) unless match.blank?
  end

  def validate_and_cast_value
    return if !self.value.is_a?(String) || value.contains_erb?
    Foreman::Parameters::Caster.new(self, :attribute_name => :value, :to => lookup_key.key_type).cast!
  rescue StandardError, SyntaxError => e
    Foreman::Logging.exception("Error while parsing #{lookup_key}", e)
    errors.add(:value, _("is invalid %s") % lookup_key.key_type)
  end

  def ensure_fqdn_exists
    md = ensure_matcher(/fqdn=(.*)/)
    return md if md == true || md == false
    fqdn = md[1].split(LookupKey::KEY_DELM)[0]
    return true if Host.unscoped.find_by_name(fqdn) || host_or_hostgroup.try(:new_record?) ||
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

  def skip_strip_attrs
    ['value']
  end
end
