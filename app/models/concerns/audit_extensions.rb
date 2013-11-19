# The audit class is part of audited plugin
module AuditExtensions
  extend ActiveSupport::Concern

  included do
    belongs_to :search_users, :class_name => 'User', :foreign_key => :user_id
    belongs_to :search_systems, :class_name => 'System', :foreign_key => :auditable_id, :conditions => "auditable_type = 'System'"
    belongs_to :search_system_groups, :class_name => 'SystemGroup', :foreign_key => :auditable_id, :conditions => "auditable_type = 'SystemGroup'"
    belongs_to :search_parameters, :class_name => 'Parameter', :foreign_key => :auditable_id, :conditions => "auditable_type = 'Parameter'"
    belongs_to :search_templates, :class_name => 'ConfigTemplate', :foreign_key => :auditable_id, :conditions => "auditable_type = 'ConfigTemplate'"
    belongs_to :search_os, :class_name => 'Operatingsystem', :foreign_key => :auditable_id, :conditions => "auditable_type = 'Operatingsystem'"
    belongs_to :search_class, :class_name => 'Puppetclass', :foreign_key => :auditable_id, :conditions => "auditable_type = 'Puppetclass'"

    scoped_search :on => [:username, :remote_address], :complete_value => true
    scoped_search :on => :audited_changes, :rename => 'changes'
    scoped_search :on => :created_at, :complete_value => true, :rename => :time, :default_order => :desc
    scoped_search :on => :action, :complete_value => { :create => 'create', :update => 'update', :delete => 'destroy' }
    scoped_search :on => :auditable_type, :complete_value => { :system => 'System', :parameter => 'Parameter', :architecture => 'Architecture',
                                                               :puppetclass => 'Puppetclass', :os => 'Operatingsystem', :system_group => 'SystemGroup',
                                                               :template => "ConfigTemplate" }, :rename => :type

    scoped_search :in => :search_parameters, :on => :name, :complete_value => true, :rename => :parameter, :only_explicit => true
    scoped_search :in => :search_templates, :on => :name, :complete_value => true, :rename => :template, :only_explicit => true
    scoped_search :in => :search_os, :on => :name, :complete_value => true, :rename => :os, :only_explicit => true
    scoped_search :in => :search_class, :on => :name, :complete_value => true, :rename => :puppetclass, :only_explicit => true
    scoped_search :in => :search_systems, :on => :name, :complete_value => true, :rename => :system, :only_explicit => true
    scoped_search :in => :search_system_groups, :on => :name, :complete_value => true, :rename => :system_group, :only_explicit => true
    scoped_search :in => :search_users, :on => :login, :complete_value => true, :rename => :user, :only_explicit => true

    before_save :ensure_username, :ensure_audtiable_and_associated_name
    after_validation :fix_auditable_type
  end

  private

  def ensure_username
    self.username ||= User.current.to_s rescue ""
  end

  def fix_auditable_type
    # STI System class should use the stub module instead of System::Base
    self.auditable_type = "System"          if auditable_type =~  /System::/
    self.associated_type = "System"         if associated_type =~ /System::/
    self.auditable_type = auditable.type  if auditable_type == "Taxonomy" && auditable
    self.associated_type = auditable.type if auditable_type == "Taxonomy" && auditable
  end

  def ensure_audtiable_and_associated_name
    self.auditable_name  ||= self.auditable.try(:to_label)
    self.associated_name ||= self.associated.try(:to_label)
  end
end
