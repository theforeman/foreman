class LookupKey < ActiveRecord::Base
  include Authorizable
  include CounterCacheFix

  KEY_TYPES = [N_("string"), N_("boolean"), N_("integer"), N_("real"), N_("array"), N_("hash"), N_("yaml"), N_("json")]
  VALIDATOR_TYPES = [N_("regexp"), N_("list") ]

  KEY_DELM = ","
  EQ_DELM  = "="

  audited :associated_with => :audit_class, :allow_mass_assignment => true, :except => :lookup_values_count
  validates_lengths_from_database

  serialize :default_value

  belongs_to :puppetclass, :inverse_of => :lookup_keys, :counter_cache => true
  has_many :environment_classes, :dependent => :destroy
  has_many :environments, ->{uniq}, :through => :environment_classes
  has_many :param_classes, :through => :environment_classes, :source => :puppetclass
  def param_class
    param_classes.first
  end

  def audit_class
    param_class || puppetclass
  end

  has_many :lookup_values, :dependent => :destroy, :inverse_of => :lookup_key
  accepts_nested_attributes_for :lookup_values,
                                :reject_if => lambda { |a| a[:value].blank? && (a[:use_puppet_default].nil? || a[:use_puppet_default] == "0")},
                                :allow_destroy => true

  before_validation :validate_and_cast_default_value, :unless => Proc.new{|p| p.use_puppet_default }
  validates :key, :uniqueness => {:scope => :is_param }, :unless => Proc.new{|p| p.is_param?}

  validates :key, :presence => true
  validates :puppetclass, :presence => true, :unless => Proc.new {|k| k.is_param?}
  validates :validator_type, :inclusion => { :in => VALIDATOR_TYPES, :message => N_("invalid")}, :allow_blank => true, :allow_nil => true
  validates :key_type, :inclusion => {:in => KEY_TYPES, :message => N_("invalid")}, :allow_blank => true, :allow_nil => true
  validate :validate_list, :validate_regexp
  validates_associated :lookup_values
  validate :ensure_type, :disable_merge_overrides, :disable_avoid_duplicates

  before_save :sanitize_path
  attr_name :key

  scoped_search :on => :key, :complete_value => true, :default_order => true
  scoped_search :on => :lookup_values_count, :rename => :values_count
  scoped_search :on => :override, :complete_value => {:true => true, :false => false}
  scoped_search :on => :merge_overrides, :complete_value => {:true => true, :false => false}
  scoped_search :on => :avoid_duplicates, :complete_value => {:true => true, :false => false}
  scoped_search :in => :param_classes, :on => :name, :rename => :puppetclass, :complete_value => true
  scoped_search :in => :lookup_values, :on => :value, :rename => :value, :complete_value => true

  default_scope lambda { order('lookup_keys.key') }

  scope :override, lambda { where(:override => true) }

  scope :smart_class_parameters_for_class, lambda {|puppetclass_ids, environment_id|
    joins(:environment_classes).where(:environment_classes => {:puppetclass_id => puppetclass_ids, :environment_id => environment_id})
  }

  scope :parameters_for_class, lambda {|puppetclass_ids, environment_id|
    override.smart_class_parameters_for_class(puppetclass_ids,environment_id)
  }

  scope :global_parameters_for_class, lambda {|puppetclass_ids|
    where(:puppetclass_id => puppetclass_ids)
  }

  scope :smart_variables, lambda { where('lookup_keys.puppetclass_id > 0').readonly(false) }
  scope :smart_class_parameters, lambda { where(:is_param => true).joins(:environment_classes).readonly(false) }

  # new methods for API instead of revealing db names
  alias_attribute :parameter, :key
  alias_attribute :variable, :key
  alias_attribute :parameter_type, :key_type
  alias_attribute :variable_type, :key_type
  alias_attribute :override_value_order, :path
  alias_attribute :override_values_count, :lookup_values_count
  alias_attribute :override_values, :lookup_values
  alias_attribute :override_value_ids, :lookup_value_ids

  # to prevent errors caused by find_resource from override_values controller
  def self.find_by_name(str)
    nil
  end

  def to_label
    "#{audit_class}::#{key}"
  end

  def is_smart_variable?
    puppetclass_id.to_i > 0
  end

  def is_smart_class_parameter?
    is_param? && environment_classes.any?
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

  def default_value_before_type_cast
    value_before_type_cast default_value
  end

  def value_before_type_cast(val)
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

  # Returns the casted value, or raises a TypeError
  def cast_validate_value(value)
    method = "cast_value_#{key_type}".to_sym
    return value unless self.respond_to? method, true
    self.send(method, value) rescue raise TypeError
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
    return false unless host.is_a?(Host::Base) || host.is_a?(Hostgroup)
    lookup_values.find_by_match(host.send(:lookup_value_match)).present?
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

  def validate_and_cast_default_value
    return true if default_value.nil? || contains_erb?(default_value)
    begin
      self.default_value = cast_validate_value self.default_value
      true
    rescue
      errors.add(:default_value, _("is invalid"))
      false
    end
  end

  def cast_value_boolean(value)
    casted = Foreman::Cast.to_bool(value)
    raise TypeError if casted.nil?
    casted
  end

  def cast_value_integer(value)
    return value.to_i if value.is_a?(Numeric)

    if value.is_a?(String)
      if value =~ /^0x[0-9a-f]+$/i
        value.to_i(16)
      elsif value =~ /^0[0-7]+$/
        value.to_i(8)
      elsif value =~ /^-?\d+$/
        value.to_i
      else
        raise TypeError
      end
    end
  end

  def cast_value_real(value)
    return value if value.is_a? Numeric
    if value.is_a?(String)
      if value =~ /\A[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?\Z/
        value.to_f
      else
        cast_value_integer value
      end
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

  def cast_value_array(value)
    return value if value.is_a? Array
    return value.to_a if not value.is_a? String and value.is_a? Enumerable
    value = load_yaml_or_json value
    raise TypeError unless value.is_a? Array
    value
  end

  def cast_value_hash(value)
    return value if value.is_a? Hash
    value = load_yaml_or_json value
    raise TypeError unless value.is_a? Hash
    value
  end

  def cast_value_yaml(value)
    YAML.load value
  end

  def cast_value_json(value)
    JSON.load value
  end

  def ensure_type
    if puppetclass_id.present? and is_param?
      self.errors.add(:base, _('Global variable or class Parameter, not both'))
    end
  end

  def validate_regexp
    return true if (validator_type != 'regexp' || (contains_erb?(default_value) && Setting[:interpolate_erb_in_parameters]))
    valid = (default_value =~ /#{validator_rule}/)
    errors.add(:default_value, _("is invalid")) unless valid
    valid
  end

  def validate_list
    return true if (validator_type != 'list' || (contains_erb?(default_value) && Setting[:interpolate_erb_in_parameters]))
    valid = validator_rule.split(KEY_DELM).map(&:strip).include?(default_value)
    errors.add(:default_value, _("%{default_value} is not one of %{validator_rule}") % { :default_value => default_value, :validator_rule => validator_rule }) unless valid
    valid
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
end
