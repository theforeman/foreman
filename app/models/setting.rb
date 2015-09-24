class Setting < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  include ActiveModel::Validations
  self.inheritance_column = 'category'

  TYPES= %w{ integer boolean hash array string }
  FROZEN_ATTRS = %w{ name category full_name }
  NONZERO_ATTRS = %w{ configuration_interval idle_timeout entries_per_page max_trend outofsync_interval }
  BLANK_ATTRS = %w{ trusted_hosts login_delegation_logout_url authorize_login_delegation_auth_source_user_autocreate root_pass default_location default_organization websockets_ssl_key websockets_ssl_cert oauth_consumer_key oauth_consumer_secret }
  URI_ATTRS = %w{ foreman_url unattended_url }

  class UriValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add attribute, _("must be a valid URI") unless %w(http https).include? URI(value).scheme
    rescue URI::InvalidURIError
      record.errors.add attribute, _("must be a valid URI")
    end
  end

  class ValueValidator < ActiveModel::Validator
    def validate(record)
      record.send("validate_#{record.name}", record)
    end
  end

  attr_accessible :name, :value, :description, :category, :settings_type, :default, :full_name

  validates_lengths_from_database
  # audit the changes to this model
  audited :only => [:value], :on => [:update], :allow_mass_assignment => true

  validates :name, :presence => true, :uniqueness => true
  validates :description, :presence => true
  validates :default, :presence => true, :unless => Proc.new {|s| s.settings_type == "boolean" || BLANK_ATTRS.include?(s.name) }
  validates :default, :inclusion => {:in => [true,false]}, :if => Proc.new {|s| s.settings_type == "boolean"}
  validates :value, :numericality => true, :length => {:maximum => 8}, :if => Proc.new {|s| s.settings_type == "integer"}
  validates :value, :numericality => {:greater_than => 0}, :if => Proc.new {|s| NONZERO_ATTRS.include?(s.name) }
  validates :value, :inclusion => {:in => [true,false]}, :if => Proc.new {|s| s.settings_type == "boolean"}
  validates :value, :presence => true, :if => Proc.new {|s| s.settings_type == "array" && !BLANK_ATTRS.include?(s.name) }
  validates :settings_type, :inclusion => {:in => TYPES}, :allow_nil => true, :allow_blank => true
  validates :value, :uri => true, :presence => true, :if => Proc.new {|s| URI_ATTRS.include?(s.name) }
  validates_with ValueValidator, :if => Proc.new {|s| s.respond_to?("validate_#{s.name}") }
  before_validation :set_setting_type_from_value
  before_save :clear_value_when_default
  before_save :clear_cache
  validate :validate_frozen_attributes
  after_find :readonly_when_overridden_in_SETTINGS
  default_scope -> { order(:name) }

  # The DB may contain settings from disabled plugins - filter them out here
  scope :live_descendants, -> { where(:category => self.descendants.map(&:to_s)) unless Rails.env.development? }

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :description, :complete_value => :true

  def self.per_page; 20 end # can't use our own settings

  def self.[](name)
    name = get_deprecated(name) || name.to_s
    cache_value = Setting.cache.read(name)
    if cache_value.nil?
      value = where(:name => name).first.try(:value)
      Setting.cache.write(name, value)
      return value
    else
      return cache_value
    end
  end

  def self.[]=(name, value)
    name   = get_deprecated(name) || name.to_s
    record = find_or_create_by_name name
    record.value = value
    record.save!
  end

  def self.method_missing(method, *args)
    super(method, *args)
  rescue NoMethodError
    method_name = method.to_s

    #setter method
    if method_name =~ /=\Z/
      self[method_name.chomp("=")] = args.first
      #getter
    else
      self[method_name]
    end
  end

  def value=(v)
    v = v.to_yaml unless v.nil?
    write_attribute :value, v
  end

  def value
    v = read_attribute(:value)
    v.nil? ? default : YAML.load(v)
  end
  alias_method :value_before_type_cast, :value

  def default
    d = read_attribute(:default)
    d.nil? ? nil : YAML.load(d)
  end

  def default=(v)
    write_attribute :default, v.to_yaml
  end
  alias_method :default_before_type_cast, :default

  def parse_string_value(val)
    case settings_type
    when "boolean"
      boolean = Foreman::Cast.to_bool(val)

      if boolean.nil?
        invalid_value_error _("must be boolean")
        return false
      end

      self.value = boolean

    when "integer"
      if val.to_s =~ /\A\d+\Z/
        self.value = val.to_i
      else
        invalid_value_error _("must be integer")
        return false
      end

    when "array"
      if val =~ /\A\[.*\]\Z/
        begin
          self.value = YAML.load(val.gsub(/(\,)(\S)/, "\\1 \\2"))
        rescue => e
          invalid_value_error e.to_s
          return false
        end
      else
        invalid_value_error _("must be an array")
        return false
      end

    when "string", nil
      #string is taken as default setting type for parsing
      self.value = val.to_s.strip

    when "hash"
      raise Foreman::Exception, "parsing hash from string is not supported"

    else
      raise Foreman::Exception.new(N_("parsing settings type '%s' from string is not defined"), settings_type)

    end
    true
  end

  def self.create(opts)
    if (s = Setting.find_by_name(opts[:name].to_s)).nil?
      column_check(opts)
      super opts.merge(:value => SETTINGS[opts[:name].to_sym] || opts[:value])
    else
      create_existing(s, opts)
    end
  end

  def self.create!(opts)
    if (s = Setting.find_by_name(opts[:name].to_s)).nil?
      column_check(opts)
      super opts.merge(:value => SETTINGS[opts[:name].to_sym] || opts[:value])
    else
      create_existing(s, opts)
    end
  end

  private

  def self.create_existing(s, opts)
    bypass_readonly(s) do
      attrs = column_check([:default, :description, :full_name])
      to_update = Hash[opts.select { |k,v| attrs.include? k }]
      to_update.merge!(:value => SETTINGS[opts[:name].to_sym]) if SETTINGS.key?(opts[:name].to_sym)
      s.update_attributes(to_update)
      s.update_column :category, opts[:category] if s.category != opts[:category]
      s.update_column :full_name, opts[:full_name] if !column_check([:full_name]).empty?
    end
    s
  end

  def self.bypass_readonly(s, &block)
    s.instance_variable_set("@readonly", false) if (old_readonly = s.readonly?)
    yield(s)
  ensure
    s.readonly! if old_readonly
  end

  def self.cache
    Rails.cache
  end

  def self.get_deprecated(setting)
    case setting.to_s
    when 'puppet_interval'
      Foreman::Deprecation.deprecation_warning('1.12', 'Use Setting[:configuration_interval] instead')
      'configuration_interval'
    when 'trusted_puppetmaster_hosts'
      Foreman::Deprecation.deprecation_warning('1.12', 'Use Setting[:trusted_hosts] instead')
      'trusted_hosts'
    when 'ignore_puppet_facts_for_provisioning'
      Foreman::Deprecation.deprecation_warning('1.12', 'Use Setting[:ignore_facts_for_provisioning] instead')
      'ignore_facts_for_provisioning'
    end
  end

  def invalid_value_error(error)
    errors.add(:value, _("is invalid: %s") % error)
  end

  def set_setting_type_from_value
    return true unless settings_type.nil?
    t = default.class.to_s.downcase
    if TYPES.include?(t)
      self.settings_type = t
    else
      self.settings_type = "integer" if default.is_a?(Integer)
      self.settings_type = "boolean" if default.is_a?(TrueClass) or default.is_a?(FalseClass)
    end
  end

  def validate_frozen_attributes
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

  def clear_value_when_default
    if read_attribute(:value) == read_attribute(:default)
      write_attribute(:value, nil)
    end
  end

  def clear_cache
    # ensures we don't have cache left overs in settings
    if Setting.cache.delete(name.to_s) == false
      Rails.logger.warn "Failed to remove #{name} from cache"
    end
  end

  def readonly_when_overridden_in_SETTINGS
    readonly! if !new_record? && SETTINGS.key?(name.to_sym)
  end

  # Methods for loading default settings

  def self.load_defaults
    # We may be executing something like rake db:migrate:reset, which destroys this table; only continue if the table exists
    Setting.first rescue return false
    # STI classes will load their own defaults
    true
  end

  def self.set(name, description, default, full_name = nil, value = nil)
    {:name => name, :value => value, :description => description, :default => default, :full_name => full_name}
  end

  def self.model_name
    ActiveModel::Name.new(Setting)
  end

  def self.column_check(opts)
    opts.keep_if { |k, v| Setting.column_names.include?(k.to_s) }
  end
end
