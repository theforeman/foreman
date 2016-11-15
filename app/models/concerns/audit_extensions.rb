# The audit class is part of audited plugin
module AuditExtensions
  extend ActiveSupport::Concern

  included do
    belongs_to :user, :class_name => 'User'
    belongs_to :search_users, :class_name => 'User', :foreign_key => :user_id
    belongs_to :search_hosts, -> { where(:audits => { :auditable_type => 'Host' }) },
      :class_name => 'Host', :foreign_key => :auditable_id
    belongs_to :search_hostgroups, :class_name => 'Hostgroup', :foreign_key => :auditable_id
    belongs_to :search_parameters, :class_name => 'Parameter', :foreign_key => :auditable_id
    belongs_to :search_templates, :class_name => 'ProvisioningTemplate', :foreign_key => :auditable_id
    belongs_to :search_os, :class_name => 'Operatingsystem', :foreign_key => :auditable_id
    belongs_to :search_class, :class_name => 'Puppetclass', :foreign_key => :auditable_id

    scoped_search :on => [:username, :remote_address], :complete_value => true
    scoped_search :on => :audited_changes, :rename => 'changes'
    scoped_search :on => :created_at, :complete_value => true, :rename => :time, :default_order => :desc
    scoped_search :on => :action, :complete_value => { :create => 'create', :update => 'update', :delete => 'destroy' }
    scoped_search :on => :auditable_type, :complete_value => { :host => 'Host', :parameter => 'Parameter', :architecture => 'Architecture',
                                                               :puppetclass => 'Puppetclass', :os => 'Operatingsystem', :hostgroup => 'Hostgroup',
                                                               :template => "ProvisioningTemplate", :lookupvalue => 'LookupValue',
                                                               :ssh_key => 'KeyPair'}, :rename => :type

    scoped_search :relation => :search_parameters, :on => :name, :complete_value => true, :rename => :parameter, :only_explicit => true
    scoped_search :relation => :search_templates, :on => :name, :complete_value => true, :rename => :template, :only_explicit => true
    scoped_search :relation => :search_os, :on => :name, :complete_value => true, :rename => :os, :only_explicit => true
    scoped_search :relation => :search_os, :on => :title, :complete_value => true, :rename => :os_title, :only_explicit => true
    scoped_search :relation => :search_class, :on => :name, :complete_value => true, :rename => :puppetclass, :only_explicit => true
    scoped_search :relation => :search_hosts, :on => :name, :complete_value => true, :rename => :host, :only_explicit => true
    scoped_search :relation => :search_hostgroups, :on => :name, :complete_value => true, :rename => :hostgroup, :only_explicit => true
    scoped_search :relation => :search_hostgroups, :on => :title, :complete_value => true, :rename => :hostgroup_title, :only_explicit => true
    scoped_search :relation => :search_users, :on => :login, :complete_value => true, :rename => :user, :only_explicit => true

    before_save :ensure_username, :ensure_auditable_and_associated_name
    before_save :filter_encrypted, :if => Proc.new {|audit| audit.audited_changes.present?}
    after_validation :fix_auditable_type

    include Authorizable

    def self.humanize_class_name
      "Audit"
    end
  end

  private

  def filter_encrypted
    self.audited_changes.each do |name,change|
      next if change.nil? || change.to_s.empty?
      if change.is_a? Array
        change.map! {|c| c.to_s.start_with?(EncryptValue::ENCRYPTION_PREFIX) ? N_("[encrypted]") : c}
      else
        audited_changes[name] = N_("[encrypted]") if change.to_s.start_with?(EncryptValue::ENCRYPTION_PREFIX)
      end
    end
  end

  def ensure_username
    self.user_as_model = User.current
    self.username = User.current.try(:to_label)
  end

  def fix_auditable_type
    # STI Host class should use the stub module instead of Host::Base
    self.auditable_type = "Host"          if auditable_type =~  /Host::/
    self.associated_type = "Host"         if associated_type =~ /Host::/
    self.auditable_type = auditable.type  if auditable_type == "Taxonomy" && auditable
    self.associated_type = auditable.type if auditable_type == "Taxonomy" && auditable
  end

  def ensure_auditable_and_associated_name
    self.auditable_name  ||= self.auditable.try(:to_label)
    self.associated_name ||= self.associated.try(:to_label)
  end
end
