# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# This file must remain idempotent.
#
# Please ensure that all templates are submitted to community-templates, then they will be synced in.

def format_errors(model = nil)
  return '(nil found)' if model.nil?
  model.errors.full_messages.join(';')
end

# Check if audits show an object was renamed or deleted
def audit_modified?(type, name)
  au = Audit.where(:auditable_type => type, :auditable_name => name)
  return true if au.where(:action => :destroy).present?
  au.where(:action => :update).each do |audit|
    return true if audit.audited_changes['name'].is_a?(Array) && audit.audited_changes['name'].first == name
  end
  false
end

# Architectures
Architecture.without_auditing do
  Architecture.find_or_create_by_name "x86_64"
  Architecture.find_or_create_by_name "i386"
end

# Template kinds
kinds = {}
[:PXELinux, :PXEGrub, :iPXE, :provision, :finish, :script, :user_data, :ZTP].each do |type|
  kinds[type] = TemplateKind.find_by_name(type)
  kinds[type] ||= TemplateKind.create :name => type
  raise "Unable to create template kind: #{format_errors kinds[type]}" if kinds[type].nil? || kinds[type].errors.any?
end

# Find known operating systems for associations
os_junos = Operatingsystem.find_all_by_type "Junos" || Operatingsystem.where("name LIKE ?", "junos")
os_solaris = Operatingsystem.find_all_by_type "Solaris"
os_suse = Operatingsystem.find_all_by_type "Suse" || Operatingsystem.where("name LIKE ?", "suse")
os_windows = Operatingsystem.find_all_by_type "Windows"

# Partition tables
Ptable.without_auditing do
  [
    { :name => 'AutoYaST entire SCSI disk', :os_family => 'Suse', :source => 'autoyast/disklayout_scsi.erb' },
    { :name => 'AutoYaST entire virtual disk', :os_family => 'Suse', :source => 'autoyast/disklayout_virtual.erb' },
    { :name => 'AutoYaST LVM', :os_family => 'Suse', :source => 'autoyast/disklayout_lvm.erb' },
    { :name => 'Jumpstart default', :os_family => 'Solaris', :source => 'jumpstart/disklayout.erb' },
    { :name => 'Jumpstart mirrored', :os_family => 'Solaris', :source => 'jumpstart/disklayout_mirrored.erb' },
    { :name => 'Kickstart default', :os_family => 'Redhat', :source => 'kickstart/disklayout.erb' },
    { :name => 'Preseed default', :os_family => 'Debian', :source => 'preseed/disklayout.erb' },
    { :name => 'Preseed custom LVM', :os_family => 'Debian', :source => 'preseed/disklayout_lvm.erb' },
    { :name => 'Junos default fake', :os_family => 'Junos', :source => 'ztp/disklayout.erb' }
  ].each do |input|
    next if Ptable.find_by_name(input[:name])
    next if audit_modified? Ptable, input[:name]
    p = Ptable.create({
      :layout => File.read(File.join("#{Rails.root}/app/views/unattended", input.delete(:source)))
    }.merge(input))
    raise "Unable to create partition table: #{format_errors p}" if p.nil? || p.errors.any?
  end
end

# Provisioning templates
ConfigTemplate.without_auditing do
  [
    # Generic PXE files
    { :name => 'PXELinux global default', :source => 'pxe/PXELinux_default.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'PXELinux default local boot', :source => 'pxe/PXELinux_local.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'PXEGrub default local boot', :source => 'pxe/PXEGrub_local.erb', :template_kind => kinds[:PXEGrub] },
    # OS specific files
    { :name => 'AutoYaST default', :source => 'autoyast/provision.erb', :template_kind => kinds[:provision], :operatingsystems => os_suse },
    { :name => 'AutoYaST SLES default', :source => 'autoyast/provision_sles.erb', :template_kind => kinds[:provision], :operatingsystems => os_suse },
    { :name => 'AutoYaST default PXELinux', :source => 'autoyast/PXELinux.erb', :template_kind => kinds[:PXELinux], :operatingsystems => os_suse },
    { :name => 'Grubby default', :source => 'scripts/grubby.erb', :template_kind => kinds[:script] },
    { :name => 'Jumpstart default', :source => 'jumpstart/provision.erb', :template_kind => kinds[:provision], :operatingsystems => os_solaris },
    { :name => 'Jumpstart default finish', :source => 'jumpstart/finish.erb', :template_kind => kinds[:finish], :operatingsystems => os_solaris },
    { :name => 'Jumpstart default PXEGrub', :source => 'jumpstart/PXEGrub.erb', :template_kind => kinds[:PXEGrub], :operatingsystems => os_solaris },
    { :name => 'Kickstart default', :source => 'kickstart/provision.erb', :template_kind => kinds[:provision] },
    { :name => 'Kickstart RHEL default', :source => 'kickstart/provision_rhel.erb', :template_kind => kinds[:provision] },
    { :name => 'Kickstart default PXELinux', :source => 'kickstart/PXELinux.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'Kickstart default iPXE', :source => 'kickstart/iPXE.erb', :template_kind => kinds[:iPXE] },
    { :name => 'Kickstart default user data', :source => 'kickstart/userdata.erb', :template_kind => kinds[:user_data] },
    { :name => 'Preseed default', :source => 'preseed/provision.erb', :template_kind => kinds[:provision] },
    { :name => 'Preseed default finish', :source => 'preseed/finish.erb', :template_kind => kinds[:finish] },
    { :name => 'Preseed default PXELinux', :source => 'preseed/PXELinux.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'Preseed default iPXE', :source => 'preseed/iPXE.erb', :template_kind => kinds[:iPXE] },
    { :name => 'Preseed default user data', :source => 'preseed/userdata.erb', :template_kind => kinds[:user_data] },
    { :name => 'WAIK default PXELinux', :source => 'waik/PXELinux.erb', :template_kind => kinds[:PXELinux], :operatingsystems => os_windows },
    { :name => "Junos default SLAX", :source => 'ztp/provision.erb', :template_kind => kinds[:provision], :operatingsystems => os_junos },
    { :name => "Junos default ZTP config", :source => 'ztp/ZTP.erb', :template_kind => kinds[:ZTP], :operatingsystems => os_junos },
    { :name => "Junos default finish", :source => 'ztp/finish.erb', :template_kind => kinds[:finish], :operatingsystems => os_junos },
    # snippets
    { :name => 'epel', :source => 'snippets/_epel.erb', :snippet => true },
    { :name => 'fix_hosts', :source => 'snippets/_fix_hosts.erb', :snippet => true },
    { :name => 'http_proxy', :source => 'snippets/_http_proxy.erb', :snippet => true },
    { :name => 'puppet.conf', :source => 'snippets/_puppet.conf.erb', :snippet => true },
    { :name => 'redhat_register', :source => 'snippets/_redhat_register.erb', :snippet => true }
  ].each do |input|
    next if ConfigTemplate.find_by_name(input[:name])
    next if audit_modified? ConfigTemplate, input[:name]
    t = ConfigTemplate.create({
      :snippet  => false,
      :template => File.read(File.join("#{Rails.root}/app/views/unattended", input.delete(:source)))
    }.merge(input))
    raise "Unable to create template #{t.name}: #{format_errors t}" if t.nil? || t.errors.any?
  end
end

# Installation media: default mirrors
Medium.without_auditing do
  [
    { :name => "CentOS mirror", :os_family => "Redhat", :path => "http://mirror.centos.org/centos/$major.$minor/os/$arch" },
    { :name => "Debian mirror", :os_family => "Debian", :path => "http://ftp.debian.org/debian/" },
    { :name => "Fedora mirror", :os_family => "Redhat", :path => "http://dl.fedoraproject.org/pub/fedora/linux/releases/$major/Fedora/$arch/os/" },
    { :name => "OpenSUSE mirror", :os_family => "Suse", :path => "http://download.opensuse.org/distribution/$major.$minor/repo/oss", :operatingsystems => os_suse },
    { :name => "Ubuntu mirror", :os_family => "Debian", :path => "http://archive.ubuntu.com/ubuntu/" }
  ].each do |input|
    next if Medium.where(['name = ? OR path = ?', input[:name], input[:path]]).any?
    next if audit_modified? Medium, input[:name]
    m = Medium.create input
    raise "Unable to create medium: #{format_errors m}" if m.nil? || m.errors.any?
  end
end

# Bookmarks
Bookmark.without_auditing do
  [
    { :name => "eventful", :query => "eventful = true", :controller=> "reports" },
    { :name => "active", :query => 'last_report > "35 minutes ago" and (status.applied > 0 or status.restarted > 0)', :controller=> "hosts" },
    { :name => "out of sync", :query => 'last_report < "30 minutes ago" andstatus.enabled = true', :controller=> "hosts" },
    { :name => "error", :query => 'last_report > "35 minutes ago" and (status.failed > 0 or status.failed_restarts > 0 or status.skipped > 0)', :controller=> "hosts" },
    { :name => "disabled", :query => 'status.enabled = false', :controller=> "hosts" },
    { :name => "ok hosts", :query => 'last_report > "35 minutes ago" and status.enabled = true and status.applied = 0 and status.failed = 0 and status.pending = 0', :controller=> "hosts" }
  ].each do |input|
    next if Bookmark.find_by_name(input[:name])
    next if audit_modified? Bookmark, input[:name]
    b = Bookmark.create({ :public => true }.merge(input))
    raise "Unable to create bookmark: #{format_errors b}" if b.nil? || b.errors.any?
  end
end

# Proxy features
[ "TFTP", "DNS", "DHCP", "Puppet", "Puppet CA", "BMC", "Chef Proxy" ].each do |input|
  f = Feature.find_or_create_by_name(input)
  raise "Unable to create proxy feature: #{format_errors f}" if f.nil? || f.errors.any?
end

AuthSource.without_auditing do
  # Auth sources
  src = AuthSourceInternal.find_by_type "AuthSourceInternal"
  src ||= AuthSourceInternal.create :name => "Internal"

  # Users
  unless User.find_by_login("admin").present?
    User.without_auditing do
      user = User.new(:login => "admin", :firstname => "Admin", :lastname => "User", :mail => Setting[:administrator])
      user.admin = true
      user.auth_source = src
      user.password = "changeme"
      User.current = user
      raise "Unable to create admin user: #{format_errors user}" unless user.save
    end
  end
end

# Compute Profiles - only create if there are not any
if ComputeProfile.unconfigured?
  ComputeProfile.without_auditing do
    [
      { :name => '1-Small' },
      { :name => '2-Medium' },
      { :name => '3-Large' },
    ].each do |input|
      cp = ComputeProfile.create input
      raise "Unable to create hardware profile: #{format_errors m}" if cp.nil? || cp.errors.any?
    end
  end
end

permissions = [
    ['Architecture', 'view_architectures'],
    ['Architecture', 'create_architectures'],
    ['Architecture', 'edit_architectures'],
    ['Architecture', 'destroy_architectures'],
    ['Audit', 'view_audit_logs'],
    ['AuthSourceLdap', 'view_authenticators'],
    ['AuthSourceLdap', 'create_authenticators'],
    ['AuthSourceLdap', 'edit_authenticators'],
    ['AuthSourceLdap', 'destroy_authenticators'],
    ['Bookmark', 'view_bookmarks'],
    ['Bookmark', 'create_bookmarks'],
    ['Bookmark', 'edit_bookmarks'],
    ['Bookmark', 'destroy_bookmarks'],
    ['ComputeProfile', 'view_compute_profiles'],
    ['ComputeProfile', 'create_compute_profiles'],
    ['ComputeProfile', 'edit_compute_profiles'],
    ['ComputeProfile', 'destroy_compute_profiles'],
    ['ComputeResource', 'view_compute_resources'],
    ['ComputeResource', 'create_compute_resources'],
    ['ComputeResource', 'edit_compute_resources'],
    ['ComputeResource', 'destroy_compute_resources'],
    ['ComputeResource', 'view_compute_resources_vms'],
    ['ComputeResource', 'create_compute_resources_vms'],
    ['ComputeResource', 'edit_compute_resources_vms'],
    ['ComputeResource', 'destroy_compute_resources_vms'],
    ['ComputeResource', 'power_compute_resources_vms'],
    ['ComputeResource', 'console_compute_resources_vms'],
    ['ConfigTemplate', 'view_templates'],
    ['ConfigTemplate', 'create_templates'],
    ['ConfigTemplate', 'edit_templates'],
    ['ConfigTemplate', 'destroy_templates'],
    ['ConfigTemplate', 'deploy_templates'],
    [nil, 'access_dashboard'],
    ['Domain', 'view_domains'],
    ['Domain', 'create_domains'],
    ['Domain', 'edit_domains'],
    ['Domain', 'destroy_domains'],
    ['Environment', 'view_environments'],
    ['Environment', 'create_environments'],
    ['Environment', 'edit_environments'],
    ['Environment', 'destroy_environments'],
    ['Environment', 'import_environments'],
    ['LookupKey', 'view_external_variables'],
    ['LookupKey', 'create_external_variables'],
    ['LookupKey', 'edit_external_variables'],
    ['LookupKey', 'destroy_external_variables'],
    ['FactValue', 'view_facts'],
    ['FactValue', 'upload_facts'],
    ['CommonParameter', 'view_globals'],
    ['CommonParameter', 'create_globals'],
    ['CommonParameter', 'edit_globals'],
    ['CommonParameter', 'destroy_globals'],
    ['HostClass', 'edit_classes'],
    ['Parameter', 'create_params'],
    ['Parameter', 'edit_params'],
    ['Parameter', 'destroy_params'],
    ['Hostgroup', 'view_hostgroups'],
    ['Hostgroup', 'create_hostgroups'],
    ['Hostgroup', 'edit_hostgroups'],
    ['Hostgroup', 'destroy_hostgroups'],
    ['Host', 'view_hosts'],
    ['Host', 'create_hosts'],
    ['Host', 'edit_hosts'],
    ['Host', 'destroy_hosts'],
    ['Host', 'build_hosts'],
    ['Host', 'power_hosts'],
    ['Host', 'console_hosts'],
    ['Host', 'ipmi_boot'],
    ['Host', 'puppetrun_hosts'],
    ['Image', 'view_images'],
    ['Image', 'create_images'],
    ['Image', 'edit_images'],
    ['Image', 'destroy_images'],
    ['Location', 'view_locations'],
    ['Location', 'create_locations'],
    ['Location', 'edit_locations'],
    ['Location', 'destroy_locations'],
    ['Location', 'assign_locations'],
    ['Medium', 'view_media'],
    ['Medium', 'create_media'],
    ['Medium', 'edit_media'],
    ['Medium', 'destroy_media'],
    ['Model', 'view_models'],
    ['Model', 'create_models'],
    ['Model', 'edit_models'],
    ['Model', 'destroy_models'],
    ['Operatingsystem', 'view_operatingsystems'],
    ['Operatingsystem', 'create_operatingsystems'],
    ['Operatingsystem', 'edit_operatingsystems'],
    ['Operatingsystem', 'destroy_operatingsystems'],
    ['Organization', 'view_organizations'],
    ['Organization', 'create_organizations'],
    ['Organization', 'edit_organizations'],
    ['Organization', 'destroy_organizations'],
    ['Organization', 'assign_organizations'],
    ['Ptable', 'view_ptables'],
    ['Ptable', 'create_ptables'],
    ['Ptable', 'edit_ptables'],
    ['Ptable', 'destroy_ptables'],
    [nil, 'view_plugins'],
    ['Puppetclass', 'view_puppetclasses'],
    ['Puppetclass', 'create_puppetclasses'],
    ['Puppetclass', 'edit_puppetclasses'],
    ['Puppetclass', 'destroy_puppetclasses'],
    ['Puppetclass', 'import_puppetclasses'],
    ['Report', 'view_reports'],
    ['Report', 'destroy_reports'],
    ['Report', 'upload_reports'],
    [nil, 'access_settings'],
    ['SmartProxy', 'view_smart_proxies'],
    ['SmartProxy', 'create_smart_proxies'],
    ['SmartProxy', 'edit_smart_proxies'],
    ['SmartProxy', 'destroy_smart_proxies'],
    ['SmartProxy', 'view_smart_proxies_autosign'],
    ['SmartProxy', 'create_smart_proxies_autosign'],
    ['SmartProxy', 'destroy_smart_proxies_autosign'],
    ['SmartProxy', 'view_smart_proxies_puppetca'],
    ['SmartProxy', 'edit_smart_proxies_puppetca'],
    ['SmartProxy', 'destroy_smart_proxies_puppetca'],
    [nil, 'view_statistics'],
    ['Subnet', 'view_subnets'],
    ['Subnet', 'create_subnets'],
    ['Subnet', 'edit_subnets'],
    ['Subnet', 'destroy_subnets'],
    ['Subnet', 'import_subnets'],
    [nil, 'view_tasks'],
    ['Trend', 'view_trends'],
    ['Trend', 'create_trends'],
    ['Trend', 'edit_trends'],
    ['Trend', 'destroy_trends'],
    ['Trend', 'update_trends'],
    ['Usergroup', 'view_usergroups'],
    ['Usergroup', 'create_usergroups'],
    ['Usergroup', 'edit_usergroups'],
    ['Usergroup', 'destroy_usergroups'],
    ['User', 'view_users'],
    ['User', 'create_users'],
    ['User', 'edit_users'],
    ['User', 'destroy_users'],
]
permissions.each do |resource, permission|
  Permission.find_or_create_by_resource_type_and_name resource, permission
end


# Roles
default_permissions =
    { 'Manager'               => [:view_architectures, :create_architectures, :edit_architectures, :destroy_architectures,
                                  :view_authenticators, :create_authenticators, :edit_authenticators, :destroy_authenticators,
                                  :view_bookmarks, :create_bookmarks, :edit_bookmarks, :destroy_bookmarks,
                                  :view_compute_resources, :create_compute_resources, :edit_compute_resources, :destroy_compute_resources,
                                  :view_compute_resources_vms, :create_compute_resources_vms, :edit_compute_resources_vms, :destroy_compute_resources_vms, :power_compute_resources_vms, :console_compute_resources_vms,
                                  :view_templates, :create_templates, :edit_templates, :destroy_templates, :deploy_templates,
                                  :view_domains, :create_domains, :edit_domains, :destroy_domains,
                                  :view_environments, :create_environments, :edit_environments, :destroy_environments, :import_environments,
                                  :view_external_variables, :create_external_variables, :edit_external_variables, :destroy_external_variables,
                                  :view_globals, :create_globals, :edit_globals, :destroy_globals,
                                  :view_hostgroups, :create_hostgroups, :edit_hostgroups, :destroy_hostgroups,
                                  :view_hosts, :create_hosts, :edit_hosts, :destroy_hosts, :build_hosts, :power_hosts, :console_hosts, :ipmi_boot, :puppetrun_hosts,
                                  :edit_classes, :create_params, :edit_params, :destroy_params,
                                  :view_images, :create_images, :edit_images, :destroy_images,
                                  :view_locations, :create_locations, :edit_locations, :destroy_locations, :assign_locations,
                                  :view_media, :create_media, :edit_media, :destroy_media,
                                  :view_models, :create_models, :edit_models, :destroy_models,
                                  :view_operatingsystems, :create_operatingsystems, :edit_operatingsystems, :destroy_operatingsystems,
                                  :view_ptables, :create_ptables, :edit_ptables, :destroy_ptables,
                                  :view_puppetclasses, :create_puppetclasses, :edit_puppetclasses, :destroy_puppetclasses, :import_puppetclasses,
                                  :view_smart_proxies, :create_smart_proxies, :edit_smart_proxies, :destroy_smart_proxies,
                                  :view_smart_proxies_autosign, :create_smart_proxies_autosign, :destroy_smart_proxies_autosign,
                                  :view_smart_proxies_puppetca, :edit_smart_proxies_puppetca, :destroy_smart_proxies_puppetca,
                                  :view_subnets, :create_subnets, :edit_subnets, :destroy_subnets, :import_subnets,
                                  :view_organizations, :create_organizations, :edit_organizations, :destroy_organizations, :assign_organizations,
                                  :view_usergroups, :create_usergroups, :edit_usergroups, :destroy_usergroups,
                                  :view_users, :create_users, :edit_users, :destroy_users, :access_settings, :access_dashboard,
                                  :view_reports, :destroy_reports, :upload_reports,
                                  :view_facts, :upload_facts, :view_audit_logs,
                                  :view_statistics, :view_trends, :create_trends, :edit_trends, :destroy_trends, :update_trends,
                                  :view_tasks, :view_plugins],
      'Edit partition tables' => [:view_ptables, :create_ptables, :edit_ptables, :destroy_ptables],
      'View hosts'            => [:view_hosts],
      'Edit hosts'            => [:view_hosts, :edit_hosts, :create_hosts, :destroy_hosts, :build_hosts],
      'Viewer'                => [:view_hosts, :view_puppetclasses, :view_hostgroups, :view_domains, :view_operatingsystems,
                                  :view_locations, :view_media, :view_models, :view_environments, :view_architectures,
                                  :view_ptables, :view_globals, :view_external_variables, :view_authenticators,
                                  :access_settings, :access_dashboard, :view_reports, :view_facts, :view_smart_proxies,
                                  :view_subnets, :view_statistics, :view_organizations, :view_usergroups, :view_users,
                                  :view_audit_logs],
      'Site manager'          => [:view_architectures, :view_audit_logs, :view_authenticators, :access_dashboard,
                                  :view_domains, :view_environments, :import_environments, :view_external_variables,
                                  :create_external_variables, :edit_external_variables, :destroy_external_variables,
                                  :view_facts, :view_globals, :view_hostgroups, :view_hosts, :view_smart_proxies_puppetca,
                                  :view_smart_proxies_autosign, :create_hosts, :edit_hosts, :destroy_hosts,
                                  :build_hosts, :view_media, :create_media, :edit_media, :destroy_media,
                                  :view_models, :view_operatingsystems, :view_ptables, :view_puppetclasses,
                                  :import_puppetclasses, :view_reports, :destroy_reports, :access_settings,
                                  :view_smart_proxies, :edit_smart_proxies, :view_subnets, :edit_subnets,
                                  :view_statistics, :view_usergroups, :create_usergroups, :edit_usergroups,
                                  :destroy_usergroups, :view_users, :edit_users],
    }

default_user_permissions = [:view_hosts, :view_puppetclasses, :view_hostgroups, :view_domains,
                            :view_operatingsystems, :view_media, :view_models, :view_environments,
                            :view_architectures, :view_ptables, :view_globals, :view_external_variables,
                            :view_authenticators, :access_settings, :access_dashboard,
                            :view_reports, :view_subnets, :view_facts, :view_locations,
                            :view_organizations, :view_statistics]
anonymous_permissions    = [:view_hosts, :view_bookmarks, :view_tasks]

def create_filters(role, collection)
  collection.group_by(&:resource_type).each do |resource, permissions|
    filter      = Filter.new
    filter.role = role
    filter.save!

    permissions.each do |permission|
      filtering            = Filtering.new
      filtering.filter     = filter
      filtering.permission = permission
      filtering.save!
    end
  end
end

def create_role(role_name, permission_names, builtin)
  return if Role.find_by_name(role_name)
  return if audit_modified? Role, role_name && builtin == 0

  role         = Role.new(:name => role_name)
  role.builtin = builtin
  role.save!
  permissions = Permission.find_all_by_name permission_names
  create_filters(role, permissions)
end

Role.without_auditing do
  default_permissions.each do |role_name, permission_names|
    create_role(role_name, permission_names, 0)
  end
  create_role('Default user', default_user_permissions, Role::BUILTIN_DEFAULT_USER)
  create_role('Anonymous', anonymous_permissions, Role::BUILTIN_ANONYMOUS)
end
