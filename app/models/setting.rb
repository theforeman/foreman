require 'resolv'

class Setting < ApplicationRecord
  audited :except => [:name, :category]
  extend FriendlyId
  friendly_id :name
  include ActiveModel::Validations
  include EncryptValue
  include PermissionName
  self.inheritance_column = 'category'

  TYPES = %w{integer boolean hash array string}
  NONZERO_ATTRS = %w{puppet_interval idle_timeout entries_per_page outofsync_interval}
  # constant BLANK_ATTRS is deprecated and all settings without custom validation allow blank values
  # if you wish to validate non-empty arrays, please add validation through the new setting DSL
  BLANK_ATTRS = %w{}
  ARRAY_HOSTNAMES = %w{trusted_hosts}
  URI_ATTRS = %w{foreman_url unattended_url}
  URI_BLANK_ATTRS = %w{login_delegation_logout_url}
  IP_ATTRS = %w{libvirt_default_console_address}
  REGEXP_ATTRS = %w{}
  EMAIL_ATTRS = %w{administrator email_reply_address}
  NOT_STRIPPED = %w{}

  class ValueValidator < ActiveModel::Validator
    def validate(record)
      record.send("validate_#{record.name}", record)
    end
  end

  validates_lengths_from_database

  validates :name, :presence => true, :uniqueness => true
  validates :value, :numericality => true, :length => {:maximum => 8}, :if => proc { |s| s.settings_type == "integer" }
  validates :value, :numericality => {:greater_than => 0}, :if => proc { |s| NONZERO_ATTRS.include?(s.name) }
  validates :value, :inclusion => {:in => [true, false]}, :if => proc { |s| s.settings_type.to_s == "boolean" }, :allow_nil => true
  validates :value, :url_schema => ['http', 'https'], :if => proc { |s| URI_ATTRS.include?(s.name) }

  validates :value, :url_schema => ['http', 'https'], :if => proc { |s| URI_BLANK_ATTRS.include?(s.name) && s.value.present? }

  validate :validate_host_owner, :if => proc { |s| s.name == "host_owner" }
  validates :value, :format => { :with => Resolv::AddressRegex }, :if => proc { |s| IP_ATTRS.include? s.name }
  validates :value, :regexp => true, :if => proc { |s| REGEXP_ATTRS.include? s.name }
  validates :value, :array_type => true, :if => proc { |s| s.settings_type == "array" }
  validates_with ValueValidator, :if => proc { |s| Foreman.settings.ready? && s.respond_to?("validate_#{s.name}") }
  validates :value, :array_hostnames_ips => true, :if => proc { |s| ARRAY_HOSTNAMES.include? s.name }
  validates :value, :email => true, :if => proc { |s| EMAIL_ATTRS.include? s.name }
  before_save :clear_value_when_default
  validate :validate_frozen_attributes
  # Custom validations are added from SettingManager class
  after_find :readonly_when_overridden
  after_save :refresh_registry_value
  default_scope -> { order(:name) }

  # Filer out settings from disabled plugins
  scope :disabled_plugins, -> { where(:category => %w[Setting].concat(descendants.map(&:to_s))) unless Rails.env.development? }

  scope :order_by, ->(attr) { except(:order).order(attr) }

  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search on: :name, complete_value: :true, operators: ['=', '~']
  scoped_search on: :description, complete_value: :true, operators: ['~']

  delegate :settings_type, :encrypted, :encrypted?, :default, to: :setting_definition, allow_nil: true

  def self.config_file
    'settings.yaml'
  end

  def self.live_descendants
    disabled_plugins.order_by(:name)
  end

  # can't use our own settings
  def self.per_page
    20
  end

  def self.humanized_category
    nil
  end

  def self.[](name)
    Foreman.settings[name]
  end

  def self.[]=(name, value)
    Foreman.settings[name] = value
  end

  def self.setting_type_from_value(value_for_type)
    t = value_for_type.class.to_s.downcase
    return t if TYPES.include?(t)
    return "integer" if value_for_type.is_a?(Integer)
    return "boolean" if value_for_type.is_a?(TrueClass) || value_for_type.is_a?(FalseClass)
  end

  def to_param
    name
  end

  def value=(v)
    v = v.to_yaml unless v.nil?
    # the has_attribute is for enabling DB migrations on older versions
    if setting_definition&.encrypted?
      # Don't re-write the attribute if the current encrypted value is identical to the new one
      current_value = self[:value]
      unless is_decryptable?(current_value) && decrypt_field(current_value) == v
        self[:value] = encrypt_field(v)
      end
    else
      self[:value] = v
    end
  end

  def value
    v = self[:value]
    v = decrypt_field(v)
    v.nil? ? default : YAML.load(v)
  end
  alias_method :value_before_type_cast, :value

  def parse_string_value(val)
    case settings_type
    when "boolean"
      boolean = Foreman::Cast.to_bool(val)

      if boolean.nil?
        invalid_value_error _("must be boolean")
      end

      self.value = boolean

    when "integer"
      if val.to_s =~ /\A\d+\Z/
        self.value = val.to_i
      else
        invalid_value_error _("must be integer")
      end

    when "array"
      if val =~ /\A\[.*\]\Z/
        begin
          self.value = YAML.load(val.gsub(/(\,)(\S)/, "\\1 \\2"))
        rescue => e
          invalid_value_error e.to_s
        end
      else
        invalid_value_error _("must be an array")
      end

    when "string", "text", nil
      # string is taken as default setting type for parsing
      self.value = NOT_STRIPPED.include?(name) ? val : val.to_s.strip

    when "hash"
      raise Foreman::SettingValueException, N_("parsing hash from string is not supported")

    else
      raise Foreman::SettingValueException.new(N_("parsing settings type '%s' from string is not defined"), settings_type)

    end
    if errors.present?
      raise Foreman::SettingValueException.new(N_("error parsing value for setting '%s': %s"), name, errors.full_messages.join(", "))
    end
    true
  end

  def self.regexp_expand_wildcard_string(string, options = {})
    prefix = options[:prefix] || '\A'
    suffix = options[:suffix] || '\Z'
    prefix + Regexp.escape(string).gsub('\*', '.*').gsub('\?', '.') + suffix
  end

  def self.convert_array_to_regexp(array, regexp_options = {})
    Regexp.new(array.map { |string| regexp_expand_wildcard_string(string, regexp_options) }.join('|'))
  end

  def has_readonly_value?
    SETTINGS.key?(name.to_sym)
  end

  def self.readonly_value(name)
    SETTINGS[name]
  end

  def read_attribute_before_type_cast(attr_name)
    return value if attr_name == :value
    super(attr_name)
  end

  def self.replace_keywords(keyword)
    keyword&.gsub '$VERSION', SETTINGS[:version].version
  end

  # Methods for loading default settings

  def self.default_settings
    []
  end

  def self.load_defaults
    return false unless table_exists?
    Foreman::Deprecation.deprecation_warning('3.4', "subclassing Setting is deprecated '#{name}' should be migrated to setting DSL "\
                                                    'see https://github.com/theforeman/foreman/blob/develop/developer_docs/how_to_create_a_plugin.asciidoc#settings for details')
    default_settings.each do |s|
      t = Setting.setting_type_from_value(s[:default]) || 'string'
      kwargs = s.except(:name).merge(type: t.to_sym, category: name, context: :deprecated)
      Foreman.settings._add(s[:name], **kwargs)
    end
    true
  end

  def self.select_collection_registry
    Foreman.settings.select_collection_registry
  end

  def self.set(name, description, default, full_name = nil, value = nil, options = {})
    if options.has_key? :collection
      select_collection_registry.add(name, options)
    end
    options[:encrypted] ||= false
    {:name => name, :value => value, :description => description, :default => default, :full_name => full_name, :encrypted => options[:encrypted]}
  end

  def select_collection
    self.class.select_collection_registry.collection_for self
  end

  def self.model_name
    ActiveModel::Name.new(Setting)
  end

  # End methods for loading default settings

  private

  def validate_host_owner
    owner_type_and_id = value
    return if owner_type_and_id.blank?
    owner = OwnerClassifier.new(owner_type_and_id).user_or_usergroup
    errors.add(:value, _("Host owner is invalid")) if owner.nil?
  end

  def invalid_value_error(error)
    errors.add(:value, _("is invalid: %s") % error)
  end

  def validate_frozen_attributes
    return true if new_record?
    changed_attributes.each do |c, old|
      # Allow settings_type to change at first (from nil) since it gets populated during validation
      if c.to_s == 'name'
        errors.add(c, _("is not allowed to change"))
        return false
      end
    end
    true
  end

  def clear_value_when_default
    if value == default
      self[:value] = nil
    end
  end

  def readonly_when_overridden
    readonly! if !new_record? && has_readonly_value?
  end

  def setting_definition
    return unless Foreman.settings.ready?
    Foreman.settings.find(name)
  end

  def refresh_registry_value
    setting_definition&.tap do |definition|
      definition.updated_at = updated_at
      definition.value_from_db = value
    end
  end
end
