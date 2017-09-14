require 'resolv'

class Setting < ApplicationRecord
  extend FriendlyId
  friendly_id :name
  include ActiveModel::Validations
  include EncryptValue
  self.inheritance_column = 'category'

  TYPES= %w{ integer boolean hash array string }
  FROZEN_ATTRS = %w{ name category full_name }
  NONZERO_ATTRS = %w{ puppet_interval idle_timeout entries_per_page max_trend outofsync_interval }
  BLANK_ATTRS = %w{ host_owner trusted_puppetmaster_hosts login_delegation_logout_url authorize_login_delegation_auth_source_user_autocreate root_pass default_location default_organization websockets_ssl_key websockets_ssl_cert oauth_consumer_key oauth_consumer_secret login_text
                    smtp_address smtp_domain smtp_user_name smtp_password smtp_openssl_verify_mode smtp_authentication sendmail_arguments sendmail_location http_proxy http_proxy_except_list}
  ARRAY_HOSTNAMES = %w{ trusted_puppetmaster_hosts }
  URI_ATTRS = %w{ foreman_url unattended_url }
  URI_BLANK_ATTRS = %w{ login_delegation_logout_url }
  IP_ATTRS = %w{ libvirt_default_console_address }
  REGEXP_ATTRS = %w{ remote_addr }
  EMAIL_ATTRS = %w{ administrator email_reply_address }

  class ValueValidator < ActiveModel::Validator
    def validate(record)
      record.send("validate_#{record.name}", record)
    end
  end

  validates_lengths_from_database
  # audit the changes to this model
  audited :except => [:name, :description, :category, :settings_type, :full_name, :encrypted], :on => [:update]

  validates :name, :presence => true, :uniqueness => true
  validates :description, :presence => true
  validates :default, :presence => true, :unless => Proc.new {|s| s.settings_type == "boolean" || BLANK_ATTRS.include?(s.name) }
  validates :default, :inclusion => {:in => [true,false]}, :if => Proc.new {|s| s.settings_type == "boolean"}
  validates :value, :numericality => true, :length => {:maximum => 8}, :if => Proc.new {|s| s.settings_type == "integer"}
  validates :value, :numericality => {:greater_than => 0}, :if => Proc.new {|s| NONZERO_ATTRS.include?(s.name) }
  validates :value, :inclusion => {:in => [true,false]}, :if => Proc.new {|s| s.settings_type == "boolean"}
  validates :value, :presence => true, :if => Proc.new {|s| s.settings_type == "array" && !BLANK_ATTRS.include?(s.name) }
  validates :settings_type, :inclusion => {:in => TYPES}, :allow_nil => true, :allow_blank => true
  validates :value, :url_schema => ['http', 'https'], :if => Proc.new {|s| URI_ATTRS.include?(s.name) }

  validates :value, :url_schema => ['http', 'https'], :if => Proc.new { |s| URI_BLANK_ATTRS.include?(s.name) && s.value.present? }

  validate :validate_host_owner, :if => Proc.new {|s| s.name == "host_owner" }
  validates :value, :format => { :with => Resolv::AddressRegex }, :if => Proc.new { |s| IP_ATTRS.include? s.name }
  validates :value, :regexp => true, :if => Proc.new { |s| REGEXP_ATTRS.include? s.name }
  validates :value, :array_type => true, :if => Proc.new { |s| s.settings_type == "array" }
  validates_with ValueValidator, :if => Proc.new {|s| s.respond_to?("validate_#{s.name}") }
  validates :value, :array_hostnames => true, :if => Proc.new { |s| ARRAY_HOSTNAMES.include? s.name }
  validates :value, :email => true, :if => Proc.new { |s| EMAIL_ATTRS.include? s.name }
  before_validation :set_setting_type_from_value
  before_save :clear_value_when_default
  before_save :clear_cache
  validate :validate_frozen_attributes
  after_find :readonly_when_overridden
  default_scope -> { order(:name) }

  # Filer out settings from disabled plugins and ones releated to taxonomies when required
  scope :disabled_plugins, -> { where(:category => self.descendants.map(&:to_s)) unless Rails.env.development? }
  scope :default_organization, -> { where('name not in (?)', 'default_organization') unless Taxonomy.enabled_taxonomies.include? 'organizations' }
  scope :organization_fact, -> { where('name not in (?)', 'organization_fact') unless Taxonomy.enabled_taxonomies.include? 'organizations' }
  scope :default_location, -> { where('name not in (?)', 'default_location') unless Taxonomy.enabled_taxonomies.include? 'locations' }
  scope :location_fact, -> { where('name not in (?)', 'location_fact') unless Taxonomy.enabled_taxonomies.include? 'locations' }
  scope :order_by, ->(attr) { except(:order).order(attr) }

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :description, :complete_value => :true

  def self.config_file
    'settings.yaml'
  end

  def self.live_descendants
    self.disabled_plugins.default_organization.organization_fact.default_location.location_fact.order_by(:category)
  end

  def self.stick_general_first
    sticky_setting = 'Setting::General'
    (where(:category => sticky_setting) + where.not(:category => sticky_setting)).group_by(&:category)
  end

  def self.per_page; 20 end # can't use our own settings

  def self.humanized_category
    nil
  end

  def self.[](name)
    name = name.to_s
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
    name   = name.to_s
    record = where(:name => name).first_or_create
    record.value = value
    record.save!
  end

  def value=(v)
    v = v.to_yaml unless v.nil?
    # the has_attribute is for enabling DB migrations on older versions
    if has_attribute?(:encrypted) && encrypted
      # Don't re-write the attribute if the current encrypted value is identical to the new one
      current_value = read_attribute(:value)
      unless is_decryptable?(current_value) && decrypt_field(current_value) == v
        write_attribute :value, encrypt_field(v)
      end
    else
      write_attribute :value, v
    end
  end

  def value
    v = read_attribute(:value)
    v = decrypt_field(v)
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
    # self.name can be set by default scope, e.g. from first_or_create use
    opts = { :name => new.name } if opts.nil?

    if (s = Setting.find_by_name(opts[:name].to_s)).nil?
      column_check(opts)
      super opts.merge(:value => readonly_value(opts[:name].to_sym) || opts[:value])
    else
      create_existing(s, opts)
    end
  end

  def self.create!(opts)
    # self.name can be set by default scope, e.g. from first_or_create use
    opts = { :name => new.name } if opts.nil?

    if (s = Setting.find_by_name(opts[:name].to_s)).nil?
      column_check(opts)
      super opts.merge(:value => readonly_value(opts[:name].to_sym) || opts[:value])
    else
      create_existing(s, opts)
    end
  end

  def self.regexp_expand_wildcard_string(string)
    "\\A#{Regexp.escape(string).gsub('\*', '.*')}\\Z"
  end

  def self.convert_array_to_regexp(array)
    Regexp.new(array.map {|string| regexp_expand_wildcard_string(string) }.join('|'))
  end

  def has_readonly_value?
    SETTINGS.key?(name.to_sym)
  end

  def self.readonly_value(name)
    SETTINGS[name]
  end

  def self.create_existing(s, opts)
    bypass_readonly(s) do
      attrs = column_check([:default, :description, :full_name, :encrypted])
      to_update = Hash[opts.select { |k,v| attrs.include? k }]
      to_update[:value] = readonly_value(s.name.to_sym) if s.has_readonly_value?
      s.update_attributes(to_update)
      s.update_column :category, opts[:category] if s.category != opts[:category]
      s.update_column :full_name, opts[:full_name] if !column_check([:full_name]).empty?
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

  def self.cache
    Rails.cache
  end

  # Methods for loading default settings

  def self.load_defaults
    # We may be executing something like rake db:migrate:reset, which destroys this table; only continue if the table exists
    Setting.first rescue return false
    # STI classes will load their own defaults
    true
  end

  def self.set(name, description, default, full_name = nil, value = nil, options = {})
    if options.has_key? :collection
      SettingsHelper.module_eval do
        define_method("#{name}_collection".to_sym) do
          collection = options[:collection].call
          collection.is_a?(Hash) ? collection : editable_select_optgroup(collection, :include_blank => options[:include_blank])
        end
      end
    end
    options[:encrypted] ||= false
    {:name => name, :value => value, :description => description, :default => default, :full_name => full_name, :encrypted => options[:encrypted]}
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
    owner_type_and_id = self.value
    return if owner_type_and_id.blank?
    owner = OwnerClassifier.new(owner_type_and_id).user_or_usergroup
    errors.add(:value, _("Host owner is invalid")) if owner.nil?
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
      self.settings_type = "boolean" if default.is_a?(TrueClass) || default.is_a?(FalseClass)
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

  def readonly_when_overridden
    readonly! if !new_record? && has_readonly_value?
  end
end
