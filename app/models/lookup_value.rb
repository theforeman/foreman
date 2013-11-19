class LookupValue < ActiveRecord::Base
  include Authorization
  belongs_to :lookup_key, :counter_cache => true
  validates :match, :presence => true, :uniqueness => {:scope => :lookup_key_id}
  delegate :key, :to => :lookup_key
  before_validation :sanitize_match
  before_validation :validate_and_cast_value
  validate :validate_list, :validate_regexp, :ensure_fqdn_exists, :ensure_system_group_exists

  attr_accessor :system_or_system_group

  serialize :value
  attr_name :value

  scope :default, lambda { where(:match => "default").limit(1) }

  scoped_search :on => :value, :complete_value => true, :default_order => true
  scoped_search :on => :match, :complete_value => true
  scoped_search :in => :lookup_key, :on => :key, :rename => :lookup_key, :complete_value => true

  def name
    value
  end

  def value_before_type_cast
    return self.value if lookup_key.nil?
    lookup_key.value_before_type_cast self.value
  end

  private

  #TODO check multi match with matchers that have space (system_group = web servers,environment = production)
  def sanitize_match
    self.match = match.split(LookupKey::KEY_DELM).map {|s| s.split(LookupKey::EQ_DELM).map(&:strip).join(LookupKey::EQ_DELM)}.join(LookupKey::KEY_DELM) unless match.blank?
  end

  def validate_and_cast_value
    return true if self.marked_for_destruction?
    begin
      self.value = lookup_key.cast_validate_value self.value
      true
    rescue
      errors.add(:value, _("is invalid %s") % lookup_key.key_type)
      false
    end
  end

  def validate_regexp
    return true unless (lookup_key.validator_type == 'regexp')
    errors.add(:value, _("is invalid")) and return false unless (value =~ /#{lookup_key.validator_rule}/)
  end

  def validate_list
    return true unless (lookup_key.validator_type == 'list')
    errors.add(:value, _("%{value} is not one of %{rules}") % { :value => value, :rules => lookup_key.validator_rule }) and return false unless lookup_key.validator_rule.split(LookupKey::KEY_DELM).map(&:strip).include?(value)
  end

  def ensure_fqdn_exists
    md = match.match(/\Afqdn=(.*)/)
    return true unless md
    return true if System.unscoped.find_by_name(md[1]) || system_or_system_group.try(:new_record?)
    errors.add(:match, _("%{match} does not match an existing system") % { :match => match }) and return false
  end

  def ensure_system_group_exists
    md = match.match(/\Asystem_group=(.*)/)
    return true unless md
    return true if SystemGroup.unscoped.find_by_name(md[1]) || SystemGroup.unscoped.find_by_label(md[1]) || system_or_system_group.try(:new_record?)
    errors.add(:match, _("%{match} does not match an existing system group") % { :match => match }) and return false
  end

  private

  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?
    allowed = case match
      when /^fqdn=(.*)/
        # check if current fqdn is in our allowed list
        System.my_systems.where(:name => $1).exists? || self.system_or_system_group.try(:new_record?)
      when /^system_group=(.*)/
        # check if current system_group is in our allowed list
        SystemGroup.my_groups.where(:label => $1).exists? || self.system_or_system_group.try(:new_record?)
      else
        false
    end
    return true if allowed
    errors.add :base, _("You do not have permission to %s this Smart Variable") % operation
    return false
  end

end
