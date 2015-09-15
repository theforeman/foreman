class LookupKey < ActiveRecord::Base
  include Authorizable
  include CounterCacheFix

  KEY_TYPES = [N_("string"), N_("boolean"), N_("integer"), N_("real"), N_("array"), N_("hash"), N_("yaml"), N_("json")]
  VALIDATOR_TYPES = [N_("regexp"), N_("list") ]

  KEY_DELM = ","
  EQ_DELM  = "="
  VALUE_REGEX =/\A[^#{KEY_DELM}]+#{EQ_DELM}[^#{KEY_DELM}]+(#{KEY_DELM}[^#{KEY_DELM}]+#{EQ_DELM}[^#{KEY_DELM}]+)*\Z/

  attr_accessible :key, :description, :override, :key_type, :default_value, :required, :validator_type, :use_puppet_default,
      :validator_rule, :path, :variable, :id, :is_param, :puppetclass_id, :lookup_values_attributes, :lookup_values

  audited :associated_with => :audit_class, :allow_mass_assignment => true, :except => :lookup_values_count
  validates_lengths_from_database

  serialize :default_value

  has_many :lookup_values, :dependent => :destroy, :inverse_of => :lookup_key
  accepts_nested_attributes_for :lookup_values,
                                :reject_if => :reject_invalid_lookup_values,
                                :allow_destroy => true

  before_validation :cast_default_value

  validates :key, :presence => true
  validates :validator_type, :inclusion => { :in => VALIDATOR_TYPES, :message => N_("invalid")}, :allow_blank => true, :allow_nil => true
  validates :key_type, :inclusion => {:in => KEY_TYPES, :message => N_("invalid")}, :allow_blank => true, :allow_nil => true
  validate :validate_default_value
  validates_associated :lookup_values
  validate :disable_merge_overrides, :disable_avoid_duplicates, :disable_merge_default

  before_save :sanitize_path
  attr_name :key

  def self.inherited(child)
    child.instance_eval do
      scoped_search :on => :key, :complete_value => true, :default_order => true
      scoped_search :on => :lookup_values_count, :rename => :values_count
      scoped_search :on => :override, :complete_value => {:true => true, :false => false}
      scoped_search :on => :merge_overrides, :complete_value => {:true => true, :false => false}
      scoped_search :on => :merge_default, :complete_value => {:true => true, :false => false}
      scoped_search :on => :avoid_duplicates, :complete_value => {:true => true, :false => false}
      scoped_search :in => :lookup_values, :on => :value, :rename => :value, :complete_value => true
    end
    super
  end

  default_scope -> { order('lookup_keys.key') }

  scope :override, -> { where(:override => true) }

  # new methods for API instead of revealing db names
  alias_attribute :parameter, :key
  alias_attribute :variable, :key
  alias_attribute :parameter_type, :key_type
  alias_attribute :variable_type, :key_type
  alias_attribute :override_value_order, :path
  alias_attribute :override_values_count, :lookup_values_count
  alias_attribute :override_values, :lookup_values
  alias_attribute :override_value_ids, :lookup_value_ids
  attr_accessible :lookup_values_attributes, :is_param, :id, :variable, :key

  # to prevent errors caused by find_resource from override_values controller
  def self.find_by_name(str)
    nil
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
    Parameterizable.parameterize("#{id}-#{key}")
  end

  def to_s
    key
  end

  def path
    path = read_attribute(:path)
    path.blank? ? array2path(Setting["Default_variables_Lookup_Path"]) : path
  end

  def path=(v)
    return unless v
    using_default = v.tr("\r","") == array2path(Setting["Default_variables_Lookup_Path"])
    write_attribute(:path, using_default ? nil : v)
  end

  def reject_invalid_lookup_values(attributes)
    attributes[:match].empty? ||
        (attributes[:value].blank? &&
            (attributes[:use_puppet_default].nil? || attributes[:use_puppet_default] == "0"))
  end

  def default_value_before_type_cast
    value_before_type_cast default_value
  end

  def value_before_type_cast(val)
    return val if val.nil? || contains_erb?(val)
    case key_type.to_sym
      when :json, :array
        begin
          val = JSON.dump(val)
        rescue JSON::GeneratorError => error
          ## http://projects.theforeman.org/issues/9553
          ## @TODO: remove when upgrading to json >= 1.8
          logger.debug "Fallback to quirks mode from error: '#{error}'"
          val = JSON.dump_in_quirks_mode(val)
        end
      when :yaml, :hash
        val = YAML.dump val
        val.sub!(/\A---\s*$\n/, '')
    end unless key_type.blank?
    val
  end

  def path_elements
    path.split.map do |paths|
      paths.split(KEY_DELM).map do |element|
        element
      end
    end
  end

  def contains_erb?(value)
    value =~ /<%.*%>/
  end

  def overridden?(host)
    return false unless host.respond_to? :lookup_values
    host.lookup_values.any? { |lv| lv.lookup_key_id == id }
  end

  def puppet?
    false
  end

  private

  # Generate possible lookup values type matches to a given host
  def path2matches(host)
    raise ::Foreman::Exception.new(N_("Invalid Host")) unless host.class.model_name == "Host"
    matches = []
    path_elements.each do |rule|
      match = []
      rule.each do |element|
        match << "#{element}#{EQ_DELM}#{attr_to_value(host,element)}"
      end
      matches << match.join(KEY_DELM)
    end
    matches
  end

  # translates an element such as domain to its real value per host
  # tries to find the host attribute first, parameters and then fallback to a puppet fact.
  def attr_to_value(host, element)
    # direct host attribute
    return host.send(element) if host.respond_to?(element)
    # host parameter
    return host.host_params[element] if host.host_params.include?(element)
    # fact attribute
    if (fn = host.fact_names.first(:conditions => { :name => element }))
      return FactValue.where(:host_id => host.id, :fact_name_id => fn.id).first.value
    end
  end

  def sanitize_path
    self.path = path.tr("\s","").downcase unless path.blank?
  end

  def array2path(array)
    raise ::Foreman::Exception.new(N_("invalid path")) unless array.is_a?(Array)
    array.map do |sub_array|
      sub_array.is_a?(Array) ? sub_array.join(KEY_DELM) : sub_array
    end.join("\n")
  end

  def cast_default_value
    return true if default_value.nil? || contains_erb?(default_value)
    begin
      Foreman::Parameters::Caster.new(self, :attribute_name => :default_value, :to => key_type).cast!
      true
    rescue
      errors.add(:default_value, _("is invalid"))
      false
    end
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
      self.errors.add(:merge_overrides, _("can only be set for array or hash"))
    end
  end

  def disable_avoid_duplicates
    if avoid_duplicates && (!merge_overrides || !supports_uniq?)
      self.errors.add(:avoid_duplicates, _("can only be set for arrays that have merge_overrides set to true"))
    end
  end

  def disable_merge_default
    if merge_default && !merge_overrides
      self.errors.add(:merge_default, _("can only be set when merge overrides is set"))
    end
  end
end
