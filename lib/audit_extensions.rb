# The audit class is part of audited plugin
# we reopen here to add search functionality
require 'audited'

module AuditExtentions
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      belongs_to :search_users, :class_name => 'User', :foreign_key => :user_id
      belongs_to :search_hosts, :class_name => 'Host', :foreign_key => :auditable_id, :conditions => "auditable_type = 'Host'"
      belongs_to :search_hostgroups, :class_name => 'Hostgroup', :foreign_key => :auditable_id, :conditions => "auditable_type = 'Hostgroup'"
      belongs_to :search_parameters, :class_name => 'Parameter', :foreign_key => :auditable_id, :conditions => "auditable_type = 'Parameter'"
      belongs_to :search_templates, :class_name => 'ConfigTemplate', :foreign_key => :auditable_id, :conditions => "auditable_type = 'ConfigTemplate'"
      belongs_to :search_os, :class_name => 'Operatingsystem', :foreign_key => :auditable_id, :conditions => "auditable_type = 'Operatingsystem'"
      belongs_to :search_class, :class_name => 'Puppetclass', :foreign_key => :auditable_id, :conditions => "auditable_type = 'Puppetclass'"

      scoped_search :on => :username, :complete_value => true
      scoped_search :on => :audited_changes, :rename => 'changes'
      scoped_search :on => :created_at, :complete_value => true, :rename => :time, :default_order => :desc
      scoped_search :on => :action, :complete_value => { :create => 'create', :update => 'update', :delete => 'destroy' }
      scoped_search :on => :auditable_type, :complete_value => { :host => 'Host', :parameter => 'Parameter', :architecture => 'Architecture', :puppetclass => 'Puppetclass', :os => 'Operatingsystem', :hostgroup => 'Hostgroup' }, :rename => :type

      scoped_search :in => :search_parameters, :on => :name, :complete_value => true, :rename => :parameter, :only_explicit => true
      scoped_search :in => :search_templates, :on => :name, :complete_value => true, :rename => :template, :only_explicit => true
      scoped_search :in => :search_os, :on => :name, :complete_value => true, :rename => :os, :only_explicit => true
      scoped_search :in => :search_class, :on => :name, :complete_value => true, :rename => :puppetclass, :only_explicit => true
      scoped_search :in => :search_hosts, :on => :name, :complete_value => true, :rename => :host, :only_explicit => true
      scoped_search :in => :search_hostgroups, :on => :name, :complete_value => true, :rename => :hostgroup, :only_explicit => true
      scoped_search :in => :search_users, :on => :login, :complete_value => true, :rename => :user, :only_explicit => true

      before_save :ensure_username, :ensure_audtiable_and_associated_name
      after_validation :fix_auditable_type

    end
  end

  module InstanceMethods
    private

    def ensure_username
      self.username ||= User.current.to_s rescue ""
    end

    def fix_auditable_type
      self.auditable_type = "Host"         if self.auditable_type == "Puppet::Rails::Host"
      self.associated_type = "Host"        if self.associated_type == "Puppet::Rails::Host"
      self.auditable_type = auditable.type if self.auditable_type == "ComputeResource"
    end

    def ensure_audtiable_and_associated_name
      self.auditable_name  ||= self.auditable.try(:to_label)
      self.associated_name ||= self.associated.try(:to_label)
    end
  end
end

Audit = Audited.audit_class
Audit.send(:include, AuditExtentions)
