class LookupKey < ActiveRecord::Base
  include Authorization

  KEY_TYPES = %w( string boolean integer real array hash yaml json )
  VALIDATOR_TYPES = %w( regexp list )

  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON', 'yes', 'YES', 'y', 'Y'].to_set
  FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF', 'no', 'NO', 'n', 'N'].to_set

  KEY_DELM = ","
  EQ_DELM  = "="

  serialize :default_value

  belongs_to :puppetclass
  has_many :environment_classes, :dependent => :destroy
  has_many :environments, :through => :environment_classes, :uniq => true
  has_one :param_class, :through => :environment_classes, :source => :puppetclass

  has_many :lookup_values, :dependent => :destroy, :inverse_of => :lookup_key
  accepts_nested_attributes_for :lookup_values, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true

  before_validation :validate_and_cast_default_value

  validates_uniqueness_of :key, :unless => Proc.new{|p| p.is_param?}
  validates_presence_of :key
  validates_presence_of :puppetclass_id, :unless => Proc.new {|k| k.is_param?}
  validates_inclusion_of :validator_type, :in => VALIDATOR_TYPES, :message => "invalid", :allow_blank => true, :allow_nil => true
  validates_inclusion_of :key_type, :in => KEY_TYPES, :message => "invalid", :allow_blank => true, :allow_nil => true
  validate :validate_list, :validate_regexp
  validates_associated :lookup_values
  validate :ensure_type

  before_save :sanitize_path

  scoped_search :on => :key, :complete_value => true, :default_order => true
  scoped_search :on => :override, :complete_value => {:true => true, :false => false}
  scoped_search :in => :param_class, :on => :name, :rename => :puppetclass, :complete_value => true
  scoped_search :in => :lookup_values, :on => :value, :rename => :value, :complete_value => true

  default_scope :order => 'lookup_keys.key'
  scope :override, where(:override => true)

  scope :parameters_for_class, lambda {|puppetclass_ids, environment_id|
    override.joins(:environment_classes).where(:environment_classes => {:puppetclass_id => puppetclass_ids, :environment_id => environment_id})
  }

  def to_param
    "#{id}-#{key}"
  end

  def to_s
    key
  end

  # params:
  #   +host: The considered Host instance.
  #   +options+: A hash containing the following, optional keys:
  #   +obs_matcher_block+: Callback to notify with extra information.
  #                        It is given a hash having the following structure:
  #                        +{ :host => #<Host>, :used_matched => "fact=value", :value => #<Value> }+
  #     +skip_fqdn+: Boolean value indicating whether to skip the fqdn matcher. Defaults to false.
  #                  Useful to give the previous value, prior to an eventual override.
  def value_for host, options = {}
    skip_fqdn = options[:skip_fqdn] || false
    obs_matcher_block = options[:obs_matcher_block]
    path2matches(host).each do |match|
      next if skip_fqdn and match =~ /^fqdn\s*=/
      if (v = lookup_values.find_by_match(match))
        obs_matcher_block.call({:host => host, :used_matcher => match, :value => v.value}) if obs_matcher_block
        return v.value
      end
    end if (!is_param || (is_param && override)) && lookup_values.any?
    default_value
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

  def value_before_type_cast val
    case key_type.to_sym
      when :json
        val = JSON.dump val
      when :yaml, :hash
        val = YAML.dump val
        val.sub!(/\A---\s*$\n/, '')
      when  :array
        val = val.inspect
    end unless key_type.blank?
    val
  end

  # Returns the casted value, or raises a TypeError
  def cast_validate_value value
    method = "cast_value_#{key_type}".to_sym
    return value unless self.respond_to? method, true
    self.send(method, value) rescue raise TypeError
  end

  def as_json(options={})
    options ||= {}
    super({:only => [:key, :is_param, :required, :override, :description, :default_value, :id]}.merge(options))
  end

  def path_elements
    path.split.map do |paths|
      paths.split(KEY_DELM).map do |element|
        element
      end
    end
  end

  private

  # Generate possible lookup values type matches to a given host
  def path2matches host
    raise "Invalid Host" unless host.class.model_name == "Host"
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
  def attr_to_value host, element
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

  def array2path array
    raise "invalid path" unless array.is_a?(Array)
    array.map do |sub_array|
      sub_array.is_a?(Array) ? sub_array.join(KEY_DELM) : sub_array
    end.join("\n")
  end


  def validate_and_cast_default_value
    return true if default_value.nil?
    begin
      self.default_value = cast_validate_value self.default_value
      true
    rescue
      errors.add(:default_value, "is invalid")
      false
    end
  end

  def cast_value_boolean value
    return true if TRUE_VALUES.include? value
    return false if FALSE_VALUES.include? value
    raise TypeError
  end

  def cast_value_integer value
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

  def cast_value_real value
    return value if value.is_a? Numeric
    if value.is_a?(String)
      if value =~ /^[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?$/
        value.to_f
      else
        cast_value_integer value
      end
    end
  end

  def load_yaml_or_json value
    return value unless value.is_a? String
    begin
      JSON.load value
    rescue
      YAML.load value
    end
  end

  def cast_value_array value
    return value if value.is_a? Array
    return value.to_a if not value.is_a? String and value.is_a? Enumerable
    value = load_yaml_or_json value
    raise TypeError unless value.is_a? Array
    value
  end

  def cast_value_hash value
    return value if value.is_a? Hash
    value = load_yaml_or_json value
    raise TypeError unless value.is_a? Hash
    value
  end

  def cast_value_yaml value
    value = YAML.load value
  end

  def cast_value_json value
    value = JSON.load value
  end

  def ensure_type
    if puppetclass_id.present? and is_param?
      self.errors.add(:base, 'Global variable or class Parameter, not both')
    end
  end

  def validate_regexp
    return true unless (validator_type == 'regexp')
    errors.add(:default_value, "is invalid") and return false unless (default_value =~ /#{validator_rule}/)
  end

  def validate_list
    return true unless (validator_type == 'list')
    errors.add(:default_value, "#{default_value} is not one of #{validator_rule}") and return false unless validator_rule.split(KEY_DELM).map(&:strip).include?(default_value)
  end

end
