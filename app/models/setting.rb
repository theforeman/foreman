class Setting < ActiveRecord::Base
  attr_accessible :name, :value, :description, :category, :settings_type, :default
  # audit the changes to this model
  audited :only => [:value], :on => [:update]

  TYPES= %w{ integer boolean hash array }
  FROZEN_ATTRS = %w{ name default description category }
  NONZERO_ATTRS = %w{ puppet_interval idle_timeout entries_per_page max_trend }
  BLANK_ATTRS = %w{ trusted_puppetmaster_hosts }
  validates_presence_of :name, :description
  validates_presence_of :default, :unless => Proc.new {|s| s.settings_type == "boolean" || BLANK_ATTRS.include?(s.name) }
  validates_inclusion_of :default, :in => [true,false], :if => Proc.new {|s| s.settings_type == "boolean"}
  validates_uniqueness_of :name
  validates_numericality_of :value, :if => Proc.new {|s| s.settings_type == "integer"}
  validates_numericality_of :value, :if => Proc.new {|s| NONZERO_ATTRS.include?(s.name) }, :greater_than => 0
  validates_inclusion_of :value, :in => [true,false], :if => Proc.new {|s| s.settings_type == "boolean"}
  validates_presence_of :value, :if => Proc.new {|s| s.settings_type == "array" && !BLANK_ATTRS.include?(s.name) }
  validates_inclusion_of :settings_type, :in => TYPES, :allow_nil => true, :allow_blank => true
  before_validation :fix_types
  before_validation :save_as_settings_type
  validate :validate_attributes
  default_scope :order => 'LOWER(settings.name)'

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :category, :complete_value => :true
  scoped_search :on => :description, :complete_value => :true

  def self.per_page; 20 end # can't use our own settings

  def self.[](name)
    name = name.to_s

    cache_value = Rails.cache.read(name)
    if cache_value.nil?
       value = where(:name => name).first.try(:value)
       cache.write(name, value)
       return value
    else
       cache_value
    end
  end

  def self.[]=(name, value)
    name   = name.to_s
    record = find_or_create_by_name name
    record.value = value
    cache.delete(name)
    record.save!
  end

  def self.method_missing(method, *args)
    super(method, *args)
  rescue NoMethodError
    method_name = method.to_s

    #setter method
    if method_name =~ /=$/
      self[method_name.chomp("=")] = args.first
      #getter
    else
      self[method_name]
    end
  end

  def value= val
    v = (val.nil? or val == default) ?  nil : val.to_yaml
    self.class.cache.delete(name.to_s)
    write_attribute :value, v
  end

  def value
    v = read_attribute(:value)
    v.nil? ? default : YAML.load(v)
  end
  alias_method :value_before_type_cast, :value

  def default
    YAML.load(read_attribute(:default))
  end

  def default=(v)
    write_attribute :default, v.to_yaml
  end

  alias_method :default_before_type_cast, :default

  private

  def self.cache
    Rails.cache
  end

  def save_as_settings_type
    return true unless settings_type.nil?
    t = default.class.to_s.downcase
    if TYPES.include?(t)
      self.settings_type = t
    else
      self.settings_type = "integer" if default.is_a?(Integer)
      self.settings_type = "boolean" if default.is_a?(TrueClass) or default.is_a?(FalseClass)
    end
  end

  def fix_types
    return true if read_attribute(:value).nil?
    case settings_type
    when "boolean"
      self.value = true  if value == "true"
      self.value = false if value == "false"
    when "integer"
      self.value = value.to_i if value =~ /\d+/
    when "array"
      if value =~ /^\s*\[.*\]\s*$/
        begin
          self.value = YAML.load(value.gsub(/(\,)(\S)/, "\\1 \\2"))
        rescue => e
          errors.add(:value, "invalid value: #{e}")
          return false
        end
      else
        errors.add(:value, "must be an array")
        return false
      end
    end
    true
  end

  def validate_attributes
    return true if new_record?
    changed_attributes.each do |c,old|
      # Allow settings_type to change at first (from nil) since it gets populated during validation
      if FROZEN_ATTRS.include?(c.to_s) || (c.to_s == :settings_type && !old.nil?)
        errors.add(c, _("is not allowed to change"))
        return false
      end
    end
    true
  end
end
