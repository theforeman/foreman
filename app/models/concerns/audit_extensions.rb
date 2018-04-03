# The audit class is part of audited plugin
module AuditExtensions
  extend ActiveSupport::Concern

  REDACTED = N_('[redacted]')

  included do
    def self.auditable_type_complete_values
      @auditable_type_complete_values ||= {
        :architecture => 'Architecture',
        :auth_source => 'AuthSource',
        :bookmark => 'Bookmark',
        :compute_attribute => 'ComputeAttribute',
        :compute_profile => 'ComputeProfile',
        :compute_resource => 'ComputeResource',
        :config_group => 'ConfigGroup',
        :domain => 'Domain',
        :host => 'Host::Base',
        :hostgroup => 'Hostgroup',
        :image => 'Image',
        :interface => 'Nic::Base',
        :location => 'Location',
        :medium => 'Medium',
        :os => 'Operatingsystem',
        :organization => 'Organization',
        :override_value => 'LookupValue',
        :partition_table => 'PartitionTable',
        :parameter => 'Parameter',
        :puppetclass => 'Puppetclass',
        :realm => 'Realm',
        :role => 'Role',
        :setting => 'Setting',
        :ssh_key => 'KeyPair',
        :smart_proxy => 'SmartProxy',
        :subnet => 'Subnet',
        :user => 'User',
        :usergroup => 'Usergroup',
        :template => 'ProvisioningTemplate',
        :provisioning_template => 'ProvisioningTemplate',
        :ptable => 'Ptable'
      }
    end

    belongs_to :user, :class_name => 'User'
    belongs_to :search_users, :class_name => 'User', :foreign_key => :user_id
    belongs_to :search_hosts, -> { where(:audits => { :auditable_type => 'Host::Base' }) },
      :class_name => 'Host::Base', :foreign_key => :auditable_id
    belongs_to :search_hostgroups, :class_name => 'Hostgroup', :foreign_key => :auditable_id
    belongs_to :search_parameters, :class_name => 'Parameter', :foreign_key => :auditable_id
    belongs_to :search_templates, :class_name => 'ProvisioningTemplate', :foreign_key => :auditable_id
    belongs_to :search_ptables, :class_name => 'Ptable', :foreign_key => :auditable_id
    belongs_to :search_os, :class_name => 'Operatingsystem', :foreign_key => :auditable_id
    belongs_to :search_class, :class_name => 'Puppetclass', :foreign_key => :auditable_id
    belongs_to :search_nics, -> { where('audits.auditable_type LIKE ?', "Nic::%") }, :class_name => 'Nic::Base', :foreign_key => :auditable_id

    scoped_search :on => [:username, :remote_address], :complete_value => true
    scoped_search :on => :audited_changes, :rename => 'changes'
    scoped_search :on => :created_at, :complete_value => true, :rename => :time, :default_order => :desc
    scoped_search :on => :action, :complete_value => { :create => 'create', :update => 'update', :delete => 'destroy' }
    scoped_search :on => :auditable_type, :complete_value => auditable_type_complete_values, :rename => :type

    scoped_search :relation => :search_parameters, :on => :name, :complete_value => true, :rename => :parameter, :only_explicit => true
    scoped_search :relation => :search_templates, :on => :name, :complete_value => true, :rename => :provisioning_template, :only_explicit => true
    scoped_search :relation => :search_ptables, :on => :name, :complete_value => true, :rename => :partition_table, :only_explicit => true
    scoped_search :relation => :search_os, :on => :name, :complete_value => true, :rename => :os, :only_explicit => true
    scoped_search :relation => :search_os, :on => :title, :complete_value => true, :rename => :os_title, :only_explicit => true
    scoped_search :relation => :search_class, :on => :name, :complete_value => true, :rename => :puppetclass, :only_explicit => true
    scoped_search :relation => :search_hosts, :on => :name, :complete_value => true, :rename => :host, :only_explicit => true
    scoped_search :relation => :search_hostgroups, :on => :name, :complete_value => true, :rename => :hostgroup, :only_explicit => true
    scoped_search :relation => :search_hostgroups, :on => :title, :complete_value => true, :rename => :hostgroup_title, :only_explicit => true
    scoped_search :relation => :search_users, :on => :login, :complete_value => true, :rename => :user, :only_explicit => true
    scoped_search :relation => :search_nics, :on => :name, :complete_value => true, :rename => :interface_fqdn, :only_explicit => true
    scoped_search :relation => :search_nics, :on => :ip, :complete_value => true, :rename => :interface_ip, :only_explicit => true
    scoped_search :relation => :search_nics, :on => :mac, :complete_value => true, :rename => :interface_mac, :only_explicit => true

    before_save :fix_auditable_type, :ensure_username, :ensure_auditable_and_associated_name, :set_taxonomies
    before_save :filter_encrypted, :if => Proc.new {|audit| audit.audited_changes.present?}
    before_save :filter_passwords, :if => Proc.new {|audit| audit.audited_changes.try(:has_key?, 'password')}
    after_create :log_audit

    include Authorizable
    include Taxonomix

    # audits can be created regardless of permissions
    def check_permissions_after_save
      true
    end

    def self.humanize_class_name
      _("Audit")
    end

    serialize :audited_changes

    # don't check user's permissions when setting the audit's taxonomies
    def ensure_taxonomies_not_escalated
      true
    end
  end

  private

  def log_audit
    Foreman::Logging.with_fields(self.audited_changes) do
      Foreman::Logging.logger('audit').info { "#{self.action} event for #{self.auditable_type} with id #{self.auditable_id}" }
    end
  end

  def filter_encrypted
    self.audited_changes.each do |name,change|
      next if change.nil? || change.to_s.empty?
      if change.is_a? Array
        change.map! {|c| c.to_s.start_with?(EncryptValue::ENCRYPTION_PREFIX) ? REDACTED : c}
      else
        audited_changes[name] = REDACTED if change.to_s.start_with?(EncryptValue::ENCRYPTION_PREFIX)
      end
    end
  end

  def filter_passwords
    if action == 'update'
      audited_changes['password'] = [REDACTED, REDACTED]
    else
      audited_changes['password'] = REDACTED
    end
  end

  def ensure_username
    self.user_as_model = User.current
    self.username = User.current.try(:to_label)
  end

  def fix_auditable_type
    # STI Host class should use the stub module instead of Host::Base
    self.auditable_type = "Host::Base" if auditable_type =~ /Host::/
    self.associated_type = "Host::Base" if associated_type =~ /Host::/
    self.auditable_type = auditable.type if ["Taxonomy", "LookupKey"].include?(auditable_type) && auditable
    self.associated_type = associated.type if ["Taxonomy", "LookupKey"].include?(associated_type) && associated
    self.auditable_type = auditable.type if auditable_type =~ /Nic::/
  end

  def ensure_auditable_and_associated_name
    # If the label changed we want to record the old one, not the new one.
    # We need to load old version from db since the auditable in memory is the
    # updated version that hasn't been saved yet.
    previous_state = auditable.class.where(id: auditable_id).first if auditable
    previous_state ||= auditable
    self.auditable_name  ||= previous_state.try(:to_label)
    self.associated_name ||= self.associated.try(:to_label)
  end

  def set_taxonomies
    if SETTINGS[:locations_enabled]
      if auditable.respond_to?(:location_id)
        self.location_ids = [auditable.location_id, audited_changes['location_id']].flatten.compact.uniq
      elsif auditable.respond_to?(:location_ids)
        self.location_ids = auditable.location_ids
      end
    end
    if SETTINGS[:organizations_enabled]
      if auditable.respond_to?(:organization_id)
        self.organization_ids = [auditable.organization_id, audited_changes['organization_id']].flatten.compact.uniq
      elsif auditable.respond_to?(:organization_ids)
        self.organization_ids = auditable.organization_ids
      end
    end
  end
end
