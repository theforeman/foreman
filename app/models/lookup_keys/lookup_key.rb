class LookupKey < ApplicationRecord
  audited :associated_with => :audit_class
  include Authorizable
  include HiddenValue
  include Classification
  include KeyType

  VALIDATOR_TYPES = [N_("regexp"), N_("list")]

  KEY_DELM = ","
  EQ_DELM  = "="
  VALUE_REGEX = /\A[^#{KEY_DELM}]+#{EQ_DELM}[^#{KEY_DELM}]+(#{KEY_DELM}[^#{KEY_DELM}]+#{EQ_DELM}[^#{KEY_DELM}]+)*\Z/
  MATCHERS_INHERITANCE = ['hostgroup', 'organization', 'location'].freeze

  validates_lengths_from_database

  serialize :default_value

  has_many :lookup_values, :dependent => :destroy, :inverse_of => :lookup_key
  accepts_nested_attributes_for :lookup_values,
    :reject_if => :reject_invalid_lookup_values,
    :allow_destroy => true

  alias_attribute :value, :default_value

  validates :key, :presence => true
  validates :validator_type, :inclusion => { :in => VALIDATOR_TYPES, :message => N_("invalid")}, :allow_blank => true, :allow_nil => true
  validates_associated :lookup_values

  before_validation :sanitize_path
  attr_name :key

  def self.inherited(child)
    child.instance_eval do
      scoped_search :on => :key, :aliases => [:parameter], :complete_value => true, :default_order => true
      scoped_search :on => :override, :complete_value => {:true => true, :false => false}
      scoped_search :on => :merge_overrides, :complete_value => {:true => true, :false => false}
      scoped_search :on => :merge_default, :complete_value => {:true => true, :false => false}
      scoped_search :on => :avoid_duplicates, :complete_value => {:true => true, :false => false}
    end
    super
  end

  def self.hidden_value
    HIDDEN_VALUE
  end

  default_scope -> { order('lookup_keys.key') }

  scope :override, -> { where(:override => true) }

  # new methods for API instead of revealing db names
  alias_attribute :parameter, :key
  alias_attribute :variable, :key
  alias_attribute :variable_type, :key_type
  alias_attribute :override_value_order, :path
  alias_attribute :override_values, :lookup_values
  alias_attribute :override_value_ids, :lookup_value_ids

  # to prevent errors caused by find_resource from override_values controller
  def self.find_by_name(str)
    nil
  end

  def reject_invalid_lookup_values(attributes)
    attributes[:match].empty?
  end

  def audit_class
    self
  end

  def to_label
    "#{audit_class}::#{key}"
  end

  def supports_merge?
    ['array', 'hash'].include?(key_type)
  end

  def supports_uniq?
    key_type == 'array'
  end

  def to_param
    # to_param is used in views to create a link to the lookup_key.
    # If the key has whitespace in it the link will break so this replaced the whitespace.
    search_key = key.tr(' ', '_') unless key.nil?
    Parameterizable.parameterize("#{id}-#{search_key}")
  end

  def to_s
    key
  end

  def path
    path = self[:path]
    path.presence || array2path(Setting["Default_parameters_Lookup_Path"])
  end

  def path=(v)
    return unless v
    using_default = v.tr("\r", "") == array2path(Setting["Default_parameters_Lookup_Path"])
    self[:path] = using_default ? nil : v
  end

  def default_value_before_type_cast
    return self[:default_value] if errors[:default_value].present?
    LookupKey.format_value_before_type_cast(default_value, key_type)
  end

  def path_elements
    path.split.map do |paths|
      paths.split(KEY_DELM).map do |element|
        element
      end
    end
  end

  def overridden?(obj)
    return false unless obj.respond_to? :lookup_values
    overridden_value(obj).present?
  end

  # check if obj has a lookupvalue that relates to this key and return it
  # we cannot search the database, in case the lookup value hasn't been saved yet
  def overridden_value(obj)
    obj.lookup_values.detect do |lookup_value|
      lookup_value.lookup_key_id == id
    end
  end

  def puppet?
    false
  end

  def sorted_values
    prio = path.downcase.split
    lookup_values.sort_by { |val| [prio.index(val.path), val.match] }
  end

  private

  def sanitize_path
    self.path = path.tr("\s", "").downcase if path.present?
  end

  def array2path(array)
    raise ::Foreman::Exception.new(N_("invalid path")) unless array.is_a?(Array)
    array.map do |sub_array|
      sub_array.is_a?(Array) ? sub_array.join(KEY_DELM) : sub_array
    end.join("\n")
  end

  def cast_default_value
    return true if default_value.nil? || default_value.contains_erb?
    begin
      Foreman::Parameters::Caster.new(self, :attribute_name => :default_value, :to => key_type).cast!
    rescue
      errors.add(:default_value, _("is invalid"))
    end
    true
  end

  def load_yaml_or_json(value)
    return value unless value.is_a? String
    begin
      JSON.load value
    rescue
      YAML.load value
    end
  end

  def validate_default_value
    Foreman::Parameters::Validator.new(self,
      :type => validator_type,
      :validate_with => validator_rule,
      :getter => :default_value).validate!
  end

  def disable_merge_overrides
    if merge_overrides && !supports_merge?
      errors.add(:merge_overrides, _("can only be set for array or hash"))
    end
  end

  def disable_avoid_duplicates
    if avoid_duplicates && (!merge_overrides || !supports_uniq?)
      errors.add(:avoid_duplicates, _("can only be set for arrays that have merge_overrides set to true"))
    end
  end

  def disable_merge_default
    if merge_default && !merge_overrides
      errors.add(:merge_default, _("can only be set when merge overrides is set"))
    end
  end

  def skip_strip_attrs
    ['default_value']
  end
end

require_dependency 'puppetclass_lookup_key'
