# Find known operating systems for associations
os_junos = Operatingsystem.find_all_by_type "Junos" || Operatingsystem.where("name LIKE ?", "junos")
os_solaris = Operatingsystem.find_all_by_type "Solaris"
os_suse = Operatingsystem.find_all_by_type "Suse" || Operatingsystem.where("name LIKE ?", "suse")
os_windows = Operatingsystem.find_all_by_type "Windows"

# Template kinds
kinds = {}
[:PXELinux, :PXEGrub, :iPXE, :provision, :finish, :script, :user_data, :ZTP].each do |type|
  kinds[type] = TemplateKind.find_by_name(type)
  kinds[type] ||= TemplateKind.create :name => type
  raise "Unable to create template kind: #{format_errors kinds[type]}" if kinds[type].nil? || kinds[type].errors.any?
end

# Provisioning templates
ConfigTemplate.without_auditing do
  [
    # Generic PXE files
    { :name => 'PXELinux global default', :source => 'pxe/PXELinux_default.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'PXELinux default local boot', :source => 'pxe/PXELinux_local.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'PXELinux default memdisk', :source => 'pxe/PXELinux_memdisk.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'PXEGrub default local boot', :source => 'pxe/PXEGrub_local.erb', :template_kind => kinds[:PXEGrub] },
    # OS specific files
    { :name => 'Alterator default', :source => 'alterator/provision.erb', :template_kind => kinds[:provision] },
    { :name => 'Alterator default finish', :source => 'alterator/finish.erb', :template_kind => kinds[:finish] },
    { :name => 'Alterator default PXELinux', :source => 'alterator/PXELinux.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'AutoYaST default', :source => 'autoyast/provision.erb', :template_kind => kinds[:provision], :operatingsystems => os_suse },
    { :name => 'AutoYaST SLES default', :source => 'autoyast/provision_sles.erb', :template_kind => kinds[:provision], :operatingsystems => os_suse },
    { :name => 'AutoYaST default PXELinux', :source => 'autoyast/PXELinux.erb', :template_kind => kinds[:PXELinux], :operatingsystems => os_suse },
    { :name => 'FreeBSD (mfsBSD) finish', :source => 'freebsd/finish_FreeBSD_mfsBSD.erb', :template_kind => kinds[:finish] },
    { :name => 'FreeBSD (mfsBSD) provision', :source => 'freebsd/provision_FreeBSD_mfsBSD.erb', :template_kind => kinds[:provision] },
    { :name => 'FreeBSD (mfsBSD) PXELinux', :source => 'freebsd/PXELinux_FreeBSD_mfsBSD.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'Grubby default', :source => 'scripts/grubby.erb', :template_kind => kinds[:script] },
    { :name => 'Jumpstart default', :source => 'jumpstart/provision.erb', :template_kind => kinds[:provision], :operatingsystems => os_solaris },
    { :name => 'Jumpstart default finish', :source => 'jumpstart/finish.erb', :template_kind => kinds[:finish], :operatingsystems => os_solaris },
    { :name => 'Jumpstart default PXEGrub', :source => 'jumpstart/PXEGrub.erb', :template_kind => kinds[:PXEGrub], :operatingsystems => os_solaris },
    { :name => 'Kickstart default', :source => 'kickstart/provision.erb', :template_kind => kinds[:provision] },
    { :name => 'Kickstart RHEL default', :source => 'kickstart/provision_rhel.erb', :template_kind => kinds[:provision] },
    { :name => 'Kickstart default finish', :source => 'kickstart/finish.erb', :template_kind => kinds[:finish] },
    { :name => 'Kickstart default PXELinux', :source => 'kickstart/PXELinux.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'Kickstart default iPXE', :source => 'kickstart/iPXE.erb', :template_kind => kinds[:iPXE] },
    { :name => 'Kickstart default user data', :source => 'kickstart/userdata.erb', :template_kind => kinds[:user_data] },
    { :name => 'Preseed default', :source => 'preseed/provision.erb', :template_kind => kinds[:provision] },
    { :name => 'Preseed default finish', :source => 'preseed/finish.erb', :template_kind => kinds[:finish] },
    { :name => 'Preseed default PXELinux', :source => 'preseed/PXELinux.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'Preseed default iPXE', :source => 'preseed/iPXE.erb', :template_kind => kinds[:iPXE] },
    { :name => 'Preseed default user data', :source => 'preseed/userdata.erb', :template_kind => kinds[:user_data] },
    { :name => 'UserData default', :source => 'cloudinit/userdata_cloudinit.erb', :template_kind => kinds[:user_data] },
    { :name => 'WAIK default PXELinux', :source => 'waik/PXELinux.erb', :template_kind => kinds[:PXELinux], :operatingsystems => os_windows },
    { :name => "Junos default SLAX", :source => 'ztp/provision.erb', :template_kind => kinds[:provision], :operatingsystems => os_junos },
    { :name => "Junos default ZTP config", :source => 'ztp/ZTP.erb', :template_kind => kinds[:ZTP], :operatingsystems => os_junos },
    { :name => "Junos default finish", :source => 'ztp/finish.erb', :template_kind => kinds[:finish], :operatingsystems => os_junos },
    # snippets
    { :name => 'alterator_pkglist', :source => 'snippets/_alterator_pkglist.erb', :snippet => true },
    { :name => 'epel', :source => 'snippets/_epel.erb', :snippet => true },
    { :name => 'fix_hosts', :source => 'snippets/_fix_hosts.erb', :snippet => true },
    { :name => 'freeipa_register', :source => 'snippets/_freeipa_register.erb', :snippet => true },
    { :name => 'http_proxy', :source => 'snippets/_http_proxy.erb', :snippet => true },
    { :name => 'puppet.conf', :source => 'snippets/_puppet.conf.erb', :snippet => true },
    { :name => 'redhat_register', :source => 'snippets/_redhat_register.erb', :snippet => true },
    { :name => 'saltstack_minion', :source => 'snippets/_saltstack_minion.erb', :snippet => true }
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
