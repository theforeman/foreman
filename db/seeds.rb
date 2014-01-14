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
[:PXELinux, :PXEGrub, :iPXE, :provision, :finish, :script, :user_data].each do |type|
  kinds[type] = TemplateKind.find_by_name(type)
  kinds[type] ||= TemplateKind.create :name => type
  raise "Unable to create template kind: #{format_errors kinds[type]}" if kinds[type].nil? || kinds[type].errors.any?
end

# Find known operating systems for associations
os_solaris = Operatingsystem.find_all_by_type "Solaris"
os_suse = Operatingsystem.find_all_by_type "Suse" || Operatingsystem.where("name LIKE ?", "suse")
os_windows = Operatingsystem.find_all_by_type "Windows"

# Partition tables
Ptable.without_auditing do
  [
    { :name => 'AutoYaST entire SCSI disk', :os_family => 'Suse', :source => 'autoyast/disklayout_scsi.erb' },
    { :name => 'AutoYaST entire virtual disk', :os_family => 'Suse', :source => 'autoyast/disklayout_virtual.erb' },
    { :name => 'Jumpstart default', :os_family => 'Solaris', :source => 'jumpstart/disklayout.erb' },
    { :name => 'Jumpstart mirrored', :os_family => 'Solaris', :source => 'jumpstart/disklayout_mirrored.erb' },
    { :name => 'Kickstart default', :os_family => 'Redhat', :source => 'kickstart/disklayout.erb' },
    { :name => 'Preseed default', :os_family => 'Debian', :source => 'preseed/disklayout.erb' },
    { :name => 'Preseed custom LVM', :os_family => 'Debian', :source => 'preseed/disklayout_lvm.erb' }
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
    { :name => 'Preseed default', :source => 'preseed/provision.erb', :template_kind => kinds[:provision] },
    { :name => 'Preseed default finish', :source => 'preseed/finish.erb', :template_kind => kinds[:finish] },
    { :name => 'Preseed default PXELinux', :source => 'preseed/PXELinux.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'WAIK default PXELinux', :source => 'waik/PXELinux.erb', :template_kind => kinds[:PXELinux], :operatingsystems => os_windows },
    # snippets
    { :name => 'epel', :source => 'snippets/_epel.erb', :snippet => true },
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
    next if Medium.find_by_name(input[:name])
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
