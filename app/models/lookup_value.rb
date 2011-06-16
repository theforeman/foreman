class LookupValue < ActiveRecord::Base
  belongs_to :lookup_key
  validates_uniqueness_of :match, :scope => :lookup_key_id
  validates_presence_of :match, :value
  delegate :key, :to => :lookup_key
  validate :validate_range, :validate_list, :validate_regexp, :validate_match
  before_validation :sanitize_match

  named_scope :default, :conditions => { :match => "default" }, :limit => 1

  default_scope :order => 'LOWER(lookup_values.value)'

  private

  # TODO: ensures that the match contain only allowed path elements
  def validate_match
  end

  #TODO check multi match with matchers that have space (hostgroup = web servers,environment = production)
  def sanitize_match
    self.match = match.split(LookupKey::KEY_DELM).map {|s| s.split(LookupKey::EQ_DELM).map(&:strip).join(LookupKey::EQ_DELM)}.join(LookupKey::KEY_DELM) unless match.blank?
  end

  def validate_regexp
    return true unless (lookup_key.validator_type == 'regexp')
    errors.add(:value, "is invalid") and return false unless (value =~ /#{lookup_key.validator_rule}/)
  end

  def validate_range
    return true unless (lookup_key.validator_type == 'range')
    errors.add(:value, "not within range #{lookup_key.validator_rule}") and return false unless eval(lookup_key.validator_rule).include?(value)
  end

  def validate_list
    return true unless (lookup_key.validator_type == 'list')
    errors.add(:value, "not in list") and return false unless lookup_key.validator_rule.split(LookupKey::KEY_DELM).map(&:strip).include?(value)
  end
end
