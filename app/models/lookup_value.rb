class LookupValue < ActiveRecord::Base
  include Authorizable
  include PuppetLookupValueExtensions

  validates_lengths_from_database
  audited :associated_with => :lookup_key
  delegate :hidden_value?, :hidden_value, :key, :to => :lookup_key, :allow_nil => true

  belongs_to :lookup_key
  validates :match, :presence => true, :uniqueness => {:scope => :lookup_key_id}, :format => LookupKey::VALUE_REGEX

  before_validation :sanitize_match
  after_destroy :cleanup_global_key

  before_validation :validate_and_cast_value, :unless => Proc.new{|p| p.omit }
  validate :validate_value, :ensure_fqdn_exists, :ensure_hostgroup_exists

  attr_accessor :host_or_hostgroup

  serialize :value
  attr_name :match

  scope :default, -> { where(:match => "default").limit(1) }
  scope :no_globals, -> { (joins(:lookup_key).where("lookup_keys.type != 'GlobalLookupKey'")).readonly(false) }
  scope :globals, -> { (joins(:lookup_key).where("lookup_keys.type = 'GlobalLookupKey'")).readonly(false) }

  scoped_search :on => :value, :complete_value => true, :default_order => true
  scoped_search :on => :match, :complete_value => true
  scoped_search :in => :lookup_key, :on => :key, :rename => :lookup_key, :alias => :name, :complete_value => true

  def safe_value
    self.hidden_value? ? "*****" : self.value
  end

  def value=(val)
    if val.is_a?(HashWithIndifferentAccess)
      super(val.deep_to_hash)
    else
      super
    end
  end

  def key=(key)
    # Only global lookup keys will try to create a key
    lk = GlobalLookupKey.where(:key=>key).first_or_create(:key => key)
    self.lookup_key_id = lk.id
    lk
  end

  def name
    match
  end

  def value_before_type_cast
    return read_attribute(:value) if errors[:value].present?
    return self.value if lookup_key.nil? || lookup_key.contains_erb?(self.value)
    lookup_key.value_before_type_cast self.value
  end

  def validate_value
    Foreman::Parameters::Validator.new(self,
      :type => lookup_key.validator_type,
      :validate_with => lookup_key.validator_rule,
      :getter => :value).validate! if lookup_key.present?
  end

  private

  def cleanup_global_key
    if lookup_key.type == 'GlobalLookupKey' && !lookup_key.should_be_global && lookup_key.lookup_values.count == 0
      lookup_key.delete
    end
  end

  #TODO check multi match with matchers that have space (hostgroup = web servers,environment = production)
  def sanitize_match
    self.match = match.split(LookupKey::KEY_DELM).map {|s| s.split(LookupKey::EQ_DELM).map(&:strip).join(LookupKey::EQ_DELM)}.join(LookupKey::KEY_DELM) unless match.blank?
  end

  def validate_and_cast_value
    return false if lookup_key.nil?
    return true if self.marked_for_destruction? || !self.value.is_a?(String)
    begin
      unless self.lookup_key.contains_erb?(value)
        Foreman::Parameters::Caster.new(self, :attribute_name => :value, :to => lookup_key.key_type).cast!
      end
      true
    rescue StandardError, SyntaxError => e
      Foreman::Logging.exception("Error while parsing #{lookup_key}", e)
      errors.add(:value, _("is invalid %s") % lookup_key.key_type)
      false
    end
  end

  def ensure_fqdn_exists
    md = ensure_matcher(/fqdn=(.*)/)
    return md if md == true || md == false
    fqdn = md[1].split(LookupKey::KEY_DELM)[0]
    return true if Host.unscoped.find_by_name(fqdn) || host_or_hostgroup.try(:new_record?)
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

  def skip_strip_attrs
    ['value']
  end
end
