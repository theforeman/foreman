# The audit class is part of audited plugin
module AuditExtensions
  extend ActiveSupport::Concern

  included do
    include Authorizable
    include SearchScope::Audit

    belongs_to :users, :class_name => 'User'
    belongs_to :search_users, :class_name => 'User', :foreign_key => :user_id
    belongs_to :search_hosts, :class_name => 'Host', :foreign_key => :auditable_id
    belongs_to :search_hostgroups, :class_name => 'Hostgroup', :foreign_key => :auditable_id
    belongs_to :search_parameters, :class_name => 'Parameter', :foreign_key => :auditable_id
    belongs_to :search_templates, :class_name => 'ConfigTemplate', :foreign_key => :auditable_id
    belongs_to :search_os, :class_name => 'Operatingsystem', :foreign_key => :auditable_id
    belongs_to :search_class, :class_name => 'Puppetclass', :foreign_key => :auditable_id

    before_save :ensure_username, :ensure_audtiable_and_associated_name
    after_validation :fix_auditable_type
  end

  private

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

  def ensure_audtiable_and_associated_name
    self.auditable_name  ||= self.auditable.try(:to_label)
    self.associated_name ||= self.associated.try(:to_label)
  end
end
