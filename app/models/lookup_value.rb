class LookupValue < ActiveRecord::Base
  include Authorization
  belongs_to :lookup_key, :counter_cache => true
  validates_uniqueness_of :match, :scope => :lookup_key_id
  validates_presence_of :match
  delegate :key, :to => :lookup_key
  before_validation :sanitize_match
  before_validation :validate_and_cast_value
  validate :validate_list, :validate_regexp

  serialize :value

  scope :default, :conditions => { :match => "default" }, :limit => 1

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

  def as_json(options={})
    options ||= {}
    super({:only => [:value, :match, :lookup_key_id, :id]}.merge(options))
  end

  private

  #TODO check multi match with matchers that have space (hostgroup = web servers,environment = production)
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

  private

  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?
    allowed = case match
      when /^fqdn=(.*)/
        # check if current fqdn is in our allowed list
        Host.my_hosts.where(:name => $1).exists?
      when /^hostgroup=(.*)/
        # check if current hostgroup is in our allowed list
        Hostgroup.my_groups.where(:label => $1).exists?
      else
        false
    end
    return true if allowed
    errors.add :base, _("You do not have permission to %s this Smart Variable") % operation
    return false
  end

end
