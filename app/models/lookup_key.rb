class LookupKey < ActiveRecord::Base

  VALIDATION_TYPES = %w( regexp list )

  KEY_DELM = ","
  EQ_DELM  = "="

  belongs_to :puppetclass
  has_many :lookup_values, :dependent => :destroy, :inverse_of => :lookup_key
  accepts_nested_attributes_for :lookup_values, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  validates_uniqueness_of :key
  validates_presence_of :key, :puppetclass_id
  validates_inclusion_of :validator_type, :in => VALIDATION_TYPES, :message => "invalid", :allow_blank => true, :allow_nil => true
  validate :validate_range_rule, :validate_range, :validate_list, :validate_regexp
  validates_associated :lookup_values

  before_save :sanitize_path

  scoped_search :on => :key, :complete_value => true, :default_order => true
  scoped_search :in => :puppetclass, :on => :name, :rename => :puppetclass, :complete_value => true
  scoped_search :in => :lookup_values, :on => :value, :rename => :value, :complete_value => true

  default_scope :order => 'LOWER(lookup_keys.key)'

  def to_param
    key
  end

  def to_s
    key
  end

  #TODO: use SQL coalesce to minimize the amount of queries
  def value_for host
    path2matches(host).each do |match|
      if (v = lookup_values.find_by_match(match))
        return v.value
      end
    end
    default_value
  end

  def path
    read_attribute(:path) || array2path(Setting["Default_variables_Lookup_Path"])
  end

  def path=(v)
    return if v == array2path(Setting["Default_variables_Lookup_Path"])
    write_attribute(:path, v)
  end

  def as_json(options={})
    super({:only => [:key, :description, :default_value, :id]}.merge(options))
  end

  private

  # Generate possible lookup values type matches to a given host
  def path2matches host
    raise "Invalid Host" unless host.is_a?(Host)
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

  def path_elements
    path.split.map do |paths|
      paths.split(KEY_DELM).map do |element|
        element
      end
    end
  end

  def sanitize_path
    self.path = path.tr("\s","").downcase unless path.blank?
  end

  def validate_range_rule
    return true unless (validator_type == 'range')
    self.errors.add(:validator_rule, "is invalid") and return false unless validator_rule =~ /^(\d|"[a-z]"|'[a-z]')+\.\.(\d|"[b-z]"|'[b-z]')+$/
  end

  def array2path array
    raise "invalid path" unless array.is_a?(Array)
    array.map do |sub_array|
      sub_array.is_a?(Array) ? sub_array.join(KEY_DELM) : sub_array
    end.join("\n")
  end

  def validate_regexp
    return true unless (validator_type == 'regexp')
    errors.add(:default_value, "is invalid") and return false unless (default_value =~ /#{validator_rule}/)
  end

  def validate_range
    return true unless (validator_type == 'range')
    errors.add(:default_value, "not within range #{validator_rule}") and return false unless eval(validator_rule).include?(default_value)
  end

  def validate_list
    return true unless (validator_type == 'list')
    errors.add(:default_value, "not in list") and return false unless validator_rule.split(KEY_DELM).map(&:strip).include?(default_value)
  end

end
