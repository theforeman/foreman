# The audit class is part of audited plugin
module AuditExtensions
  extend ActiveSupport::Concern

  included do
    belongs_to :search_users, :class_name => 'User', :foreign_key => :user_id
    belongs_to :search_hosts, :class_name => 'Host', :foreign_key => :auditable_id
    belongs_to :search_hostgroups, :class_name => 'Hostgroup', :foreign_key => :auditable_id
    belongs_to :search_parameters, :class_name => 'Parameter', :foreign_key => :auditable_id
    belongs_to :search_templates, :class_name => 'ConfigTemplate', :foreign_key => :auditable_id
    belongs_to :search_os, :class_name => 'Operatingsystem', :foreign_key => :auditable_id
    belongs_to :search_class, :class_name => 'Puppetclass', :foreign_key => :auditable_id

    scoped_search :on => [:username, :remote_address], :complete_value => true
    scoped_search :on => :audited_changes, :rename => 'changes'
    scoped_search :on => :created_at, :complete_value => true, :rename => :time, :default_order => :desc
    scoped_search :on => :action, :complete_value => { :create => 'create', :update => 'update', :delete => 'destroy' }
    scoped_search :on => :auditable_type, :complete_value => { :host => 'Host', :parameter => 'Parameter', :architecture => 'Architecture',
                                                               :puppetclass => 'Puppetclass', :os => 'Operatingsystem', :hostgroup => 'Hostgroup',
                                                               :template => "ConfigTemplate" }, :rename => :type

    scoped_search :in => :search_parameters, :on => :name, :complete_value => true, :rename => :parameter, :only_explicit => true
    scoped_search :in => :search_templates, :on => :name, :complete_value => true, :rename => :template, :only_explicit => true
    scoped_search :in => :search_os, :on => :name, :complete_value => true, :rename => :os, :only_explicit => true
    scoped_search :in => :search_class, :on => :name, :complete_value => true, :rename => :puppetclass, :only_explicit => true
    scoped_search :in => :search_hosts, :on => :name, :complete_value => true, :rename => :host, :only_explicit => true
    scoped_search :in => :search_hostgroups, :on => :name, :complete_value => true, :rename => :hostgroup, :only_explicit => true
    scoped_search :in => :search_users, :on => :login, :complete_value => true, :rename => :user, :only_explicit => true

    before_save :ensure_username, :ensure_audtiable_and_associated_name
    after_validation :fix_auditable_type

    include Authorizable
  end

  private

  def ensure_username
    self.username ||= User.current.to_s rescue ""
  end

  def fix_auditable_type
    # STI Host class should use the stub module instead of Host::Base
    self.auditable_type = "Host"          if auditable_type =~  /Host::/
    self.associated_type = "Host"         if associated_type =~ /Host::/
    self.auditable_type = auditable.type  if auditable_type == "Taxonomy" && auditable
    self.associated_type = auditable.type if auditable_type == "Taxonomy" && auditable
  end

  def ensure_audtiable_and_associated_name
    self.auditable_name  ||= self.auditable.try(:to_label)
    self.associated_name ||= self.associated.try(:to_label)
  end
end
