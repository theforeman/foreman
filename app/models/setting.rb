require 'resolv'

class Setting < ApplicationRecord
  audited :except => [:name, :description, :category, :settings_type, :full_name, :encrypted], :on => [:update]
  extend FriendlyId
  friendly_id :name
  include ActiveModel::Validations
  include EncryptValue
  include PermissionName
  self.inheritance_column = 'category'

  graphql_type '::Types::Setting'

  TYPES = %w{integer boolean hash array string}
  FROZEN_ATTRS = %w{name category}
  NONZERO_ATTRS = %w{puppet_interval idle_timeout entries_per_page outofsync_interval}
  BLANK_ATTRS = %w{ host_owner trusted_hosts login_delegation_logout_url root_pass default_location default_organization websockets_ssl_key websockets_ssl_cert oauth_consumer_key oauth_consumer_secret login_text oidc_audience oidc_issuer oidc_algorithm
                    smtp_address smtp_domain smtp_user_name smtp_password smtp_openssl_verify_mode smtp_authentication sendmail_arguments sendmail_location http_proxy http_proxy_except_list default_locale default_timezone ssl_certificate ssl_ca_file ssl_priv_key default_pxe_item_global default_pxe_item_local oidc_jwks_url instance_title }
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
  validates :description, :presence => true
  validates :default, :presence => true, :unless => proc { |s| s.settings_type == "boolean" || BLANK_ATTRS.include?(s.name) }
  validates :default, :inclusion => {:in => [true, false]}, :if => proc { |s| s.settings_type == "boolean" }
  validates :value, :numericality => true, :length => {:maximum => 8}, :if => proc { |s| s.settings_type == "integer" }
  validates :value, :numericality => {:greater_than => 0}, :if => proc { |s| NONZERO_ATTRS.include?(s.name) }
  validates :value, :inclusion => {:in => [true, false]}, :if => proc { |s| s.settings_type == "boolean" }
  validates :value, :presence => true, :if => proc { |s| s.settings_type == "array" && !BLANK_ATTRS.include?(s.name) }
  validates :settings_type, :inclusion => {:in => TYPES}, :allow_nil => true, :allow_blank => true
  validates :value, :url_schema => ['http', 'https'], :if => proc { |s| URI_ATTRS.include?(s.name) }

  validates :value, :url_schema => ['http', 'https'], :if => proc { |s| URI_BLANK_ATTRS.include?(s.name) && s.value.present? }

  validate :validate_host_owner, :if => proc { |s| s.name == "host_owner" }
  validates :value, :format => { :with => Resolv::AddressRegex }, :if => proc { |s| IP_ATTRS.include? s.name }
  validates :value, :regexp => true, :if => proc { |s| REGEXP_ATTRS.include? s.name }
  validates :value, :array_type => true, :if => proc { |s| s.settings_type == "array" }
  validates_with ValueValidator, :if => proc { |s| Foreman.settings.ready? && s.respond_to?("validate_#{s.name}") }
  validates :value, :array_hostnames_ips => true, :if => proc { |s| ARRAY_HOSTNAMES.include? s.name }
  validates :value, :email => true, :if => proc { |s| EMAIL_ATTRS.include? s.name }
  before_validation :set_setting_type_from_value
  before_save :clear_value_when_default
  validate :validate_frozen_attributes
  after_find :readonly_when_overridden
  after_save :refresh_registry_value
  default_scope -> { order(:name) }

  # Filer out settings from disabled plugins
  scope :disabled_plugins, -> { where(:category => descendants.map(&:to_s)) unless Rails.env.development? }

  scope :order_by, ->(attr) { except(:order).order(attr) }

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :description, :complete_value => :true

  def self.config_file
    'settings.yaml'
  end

  def self.live_descendants
    disabled_plugins.order_by(:full_name)
  end

  def self.stick_general_first
    sticky_setting = 'Setting::General'
    (where(:category => sticky_setting) + where.not(:category => sticky_setting)).group_by(&:category)
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
    if has_attribute?(:encrypted) && encrypted
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

  def default
    d = self[:default]
    d.nil? ? nil : YAML.load(d)
  end

  def default=(v)
    self[:default] = v.to_yaml
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
      # string is taken as default setting type for parsing
      self.value = NOT_STRIPPED.include?(name) ? val : val.to_s.strip

    when "hash"
      raise Foreman::Exception, "parsing hash from string is not supported"

    else
      raise Foreman::Exception.new(N_("parsing settings type '%s' from string is not defined"), settings_type)

    end
    true
  end

  # in order to avoid code duplication, this method was introduced
  def self.create_find_by_name(opts)
    # self.name can be set by default scope, e.g. from first_or_create use
    opts ||= { name: new.name }
    opts.symbolize_keys!

    s = Setting.find_by_name(opts[:name].to_s)
    return create_existing(s, opts) if s

    column_check(opts)
    if block_given?
      yield opts.merge!(value: readonly_value(opts[:name].to_sym) || opts[:value])
    end
  end

  def self.create(opts)
    create_find_by_name(opts) { super }
  end

  def self.create!(opts)
    create_find_by_name(opts) { super }
  end

  def self.regexp_expand_wildcard_string(string, options = {})
    prefix = options[:prefix] || '\A'
    suffix = options[:suffix] || '\Z'
    prefix + Regexp.escape(string).gsub('\*', '.*') + suffix
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

  def self.create_existing(s, opts)
    bypass_readonly(s) do
      attrs = column_check([:default, :description, :full_name, :encrypted])
      to_update = Hash[opts.select { |k, v| attrs.include? k }]
      to_update[:value] = readonly_value(s.name.to_sym) if s.has_readonly_value?
      # default is converted to yaml so we need to convert the yaml here too,
      # in order to check, if the update of default is needed
      # if it is the same, we don't try to update default, it would trigger
      # update query for every setting
      to_update.delete(:default) if to_update[:default].to_yaml.strip == s[:default]
      s.attributes = to_update
      s.save(validate: false)
      s.update_column :category, opts[:category] if s.category != opts[:category]
      s.update_column :full_name, opts[:full_name] if column_check([:full_name]).present? && s.full_name != opts[:full_name]
      raw_value = s.read_attribute(:value)
      if s.is_encryptable?(raw_value) && attrs.include?(:encrypted) && opts[:encrypted]
        s.update_column :value, s.encrypt_field(raw_value)
      end
      if s.is_decryptable?(raw_value) && attrs.include?(:encrypted) && !opts[:encrypted]
        s.update_column :value, s.decrypt_field(raw_value)
      end
    end
    s
  end

  def self.bypass_readonly(s, &block)
    s.instance_variable_set("@readonly", false) if (old_readonly = s.readonly?)
    yield(s)
  ensure
    s.readonly! if old_readonly
  end

  # Methods for loading default settings

  def self.default_settings
    []
  end

  def self.load_defaults
    return false unless table_exists?
    dbcache = Hash[Setting.where(:category => name).map { |s| [s.name, s] }]
    transaction do
      default_settings.compact.each do |s|
        val = s.update(:category => name).symbolize_keys
        dbcache.key?(val[:name]) ? create_existing(dbcache[val[:name]], s) : create!(s)
      end
    end
    true
  end

  def self.select_collection_registry
    @@select_collection ||= SettingSelectCollection.new
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

  def self.column_check(opts)
    opts.keep_if { |k, v| Setting.column_names.include?(k.to_s) }
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

  def set_setting_type_from_value
    self.settings_type ||= self.class.setting_type_from_value(default)
  end

  def validate_frozen_attributes
    return true if new_record?
    changed_attributes.each do |c, old|
      # Allow settings_type to change at first (from nil) since it gets populated during validation
      if FROZEN_ATTRS.include?(c.to_s) || (c.to_s == :settings_type && !old.nil?)
        errors.add(c, _("is not allowed to change"))
        return false
      end
    end
    true
  end

  def clear_value_when_default
    if self[:value] == self[:default]
      self[:value] = nil
    end
  end

  def readonly_when_overridden
    readonly! if !new_record? && has_readonly_value?
  end

  def refresh_registry_value
    return unless Foreman.settings.ready?
    Foreman.settings.find(name)&.tap do |definition|
      definition.updated_at = updated_at
      definition.value = value
    end
  end
end
