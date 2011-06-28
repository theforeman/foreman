class Setting < ActiveRecord::Base
  attr_accessible :name, :value, :description, :category, :settings_type, :default

  TYPES= %w{ integer boolean hash array }
  FROZEN_ATTRS = %w{ name default description category settings_type }
  validates_presence_of :name, :description
  validates_uniqueness_of :name
  validates_numericality_of :value, :if => Proc.new {|s| s.settings_type == "integer"}
  validates_inclusion_of :value, :in => [true,false], :if => Proc.new {|s| s.settings_type == "boolean"}
  validates_inclusion_of :settings_type, :in => TYPES, :allow_nil => true, :allow_blank => true
  serialize :value
  serialize :default
  before_validation :fix_booleans, :strip_unneeded_value
  before_save :save_as_settings_type
  validate :validate_attributes

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :category, :complete_value => :true
  scoped_search :on => :description, :complete_value => :true

  def self.[](name)
    if record = first(:conditions => {:name => name.to_s})
      record.value
    end
  end

  def self.[]=(name, value)
    record = find_or_create_by_name name.to_s
    record.value = value
    record.save
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

  def value
    v = (super.blank? ? default : super)
    case settings_type
    when "integer"
      v = v.to_i
    when "boolean"
      v = ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(v)
    end
    v
  end

  private

  def save_as_settings_type
    t = default.class.to_s.downcase
    if TYPES.include?(t)
      self.settings_type = t
    else
      self.settings_type = "integer" if default.is_a?(Integer)
      self.settings_type = "boolean" if default.is_a?(TrueClass) or default.is_a?(FalseClass)
    end
  end

  def fix_booleans
    if settings_type = "boolean"
      self.value = true  if value == "true"
      self.value = false if value == "false"
    end
  end

  def strip_unneeded_value
    self.value = nil if value == default
  end

  def self.create_default_settings
    domain = Facter.domain
    [
      set('administrator', "The Default administrator email address", "root@#{domain}"),
      set('foreman_url',   "The URL where your foreman instance is running on", "http://foreman.#{domain}"),
    ].each { |s| create s.update(:category => "General")}

    [
      set('root_pass',     "Default ecrypted root password on provisioned hosts default is 123123", "xybxa6JUkz63w"),
      set('safemode_render', "Enable safe mode config templates rendinging(recommended)", true),
      set('ssl_certificate', "SSL Certificate path that foreman would use to communicate with its proxies", Puppet.settings[:hostcert]),
      set('ssl_ca_file',  "SSL CA file that foreman would use to communicate with its proxies", Puppet.settings[:localcacert]),
      set('ssl_priv_key', "SSL Private Key file that foreman would use to communicate with its proxies", Puppet.settings[:hostprivkey]),
      set('ignore_puppet_facts_for_provisioning', "Does not update ipaddress and MAC values from puppet facts", false)
    ].each { |s| create s.update(:category => "Provisioning")}

    [
      set('puppet_interval', "Puppet interval in minutes", 30 ),
      set('default_puppet_environment',"The Puppet environment foreman would default to in case it can't auto detect it", "production"),
      set('modulepath',"The Puppet default module path in case that Foreman can't auto detect it", "/etc/puppet/modules"),
      set('document_root', "Document root where puppetdoc files should be created", "#{RAILS_ROOT}/public/puppet/rdoc"),
      set('puppetrun', "Enables Puppetrun Support", false),
      set('puppet_server', "Default Puppet Server hostname", "puppet"),
      set('failed_report_email_notification', "Enable Email Alerts per each failed puppet report", false),
      set('using_storeconfigs', "Foreman is sharing its database with Puppet Store configs", (!Puppet.settings.instance_variable_get(:@values)[:master][:dbadapter].empty? rescue false))
    ].compact.each { |s| create s.update(:category => "Puppet")}


  end

  def self.set name, description, default, value = nil
    value ||= SETTINGS[name.to_sym]
    {:name => name, :value => value, :description => description, :default => default}
  end

  def validate_attributes
    return true if new_record?
    changed_attributes.keys.each do |c|
      if FROZEN_ATTRS.include?(c.to_s)
        errors.add(c, "is not allowed to change")
        return false
      end
    end
    true
  end

end
