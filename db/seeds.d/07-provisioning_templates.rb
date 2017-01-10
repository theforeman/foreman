# Find known operating systems for associations
os_junos   = Operatingsystem.where(:type => "Junos") || Operatingsystem.where("name LIKE ?", "junos")
os_solaris = Operatingsystem.where(:type => "Solaris")
os_suse    = Operatingsystem.where(:type => "Suse") || Operatingsystem.where("name LIKE ?", "suse")
os_windows = Operatingsystem.where(:type => "Windows")

# Template kinds
kinds = {}
TemplateKind.default_template_labels.keys.collect(&:to_sym).each do |type|
  kinds[type] = TemplateKind.unscoped.find_by_name(type)
  kinds[type] ||= TemplateKind.unscoped.create(:name => type)
  raise "Unable to create template kind: #{format_errors kinds[type]}" if kinds[type].nil? || kinds[type].errors.any?
end

# Provisioning templates
organizations = Organization.unscoped.all
locations = Location.unscoped.all
ProvisioningTemplate.without_auditing do
  [
    # Generic PXE files
    { :name => 'PXELinux global default', :source => 'pxe/PXELinux_default.erb', :template_kind => kinds[:PXELinux], :locked => true },
    { :name => 'PXEGrub global default', :source => 'pxe/PXEGrub_default.erb', :template_kind => kinds[:PXEGrub], :locked => true },
    { :name => 'PXEGrub2 global default', :source => 'pxe/PXEGrub2_default.erb', :template_kind => kinds[:PXEGrub2], :locked => true },
    { :name => 'PXELinux default local boot', :source => 'pxe/PXELinux_local.erb', :template_kind => kinds[:PXELinux], :locked => true },
    { :name => 'PXEGrub default local boot', :source => 'pxe/PXEGrub_local.erb', :template_kind => kinds[:PXEGrub], :locked => true },
    { :name => 'PXEGrub2 default local boot', :source => 'pxe/PXEGrub2_local.erb', :template_kind => kinds[:PXEGrub2], :locked => true },
    { :name => 'PXELinux default memdisk', :source => 'pxe/PXELinux_memdisk.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'PXELinux chain iPXE', :source => 'pxe/PXELinux_chain_iPXE.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'PXELinux chain iPXE UNDI', :source => 'pxe/PXELinux_chain_iPXE_UNDI.erb', :template_kind => kinds[:PXELinux] },
    # OS specific files
    { :name => 'Alterator default', :source => 'alterator/provision.erb', :template_kind => kinds[:provision] },
    { :name => 'Alterator default finish', :source => 'alterator/finish.erb', :template_kind => kinds[:finish] },
    { :name => 'Alterator default PXELinux', :source => 'alterator/PXELinux.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'Atomic Kickstart default', :source => 'kickstart/provision_atomic.erb', :template_kind => kinds[:provision] },
    { :name => 'AutoYaST default', :source => 'autoyast/provision.erb', :template_kind => kinds[:provision], :operatingsystems => os_suse },
    { :name => 'AutoYaST SLES default', :source => 'autoyast/provision_sles.erb', :template_kind => kinds[:provision], :operatingsystems => os_suse },
    { :name => 'AutoYaST default PXELinux', :source => 'autoyast/PXELinux.erb', :template_kind => kinds[:PXELinux], :operatingsystems => os_suse },
    { :name => 'AutoYaST default iPXE', :source => 'autoyast/iPXE.erb', :template_kind => kinds[:iPXE] },
    { :name => 'CoreOS provision', :source => 'coreos/provision.erb', :template_kind => kinds[:provision]},
    { :name => 'CoreOS PXELinux', :source => 'coreos/PXELinux.erb', :template_kind => kinds[:PXELinux]},
    { :name => 'FreeBSD (mfsBSD) finish', :source => 'freebsd/finish_FreeBSD_mfsBSD.erb', :template_kind => kinds[:finish] },
    { :name => 'FreeBSD (mfsBSD) provision', :source => 'freebsd/provision_FreeBSD_mfsBSD.erb', :template_kind => kinds[:provision] },
    { :name => 'FreeBSD (mfsBSD) PXELinux', :source => 'freebsd/PXELinux_FreeBSD_mfsBSD.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'Grubby default', :source => 'scripts/grubby.erb', :template_kind => kinds[:script] },
    { :name => 'Jumpstart default', :source => 'jumpstart/provision.erb', :template_kind => kinds[:provision], :operatingsystems => os_solaris },
    { :name => 'Jumpstart default finish', :source => 'jumpstart/finish.erb', :template_kind => kinds[:finish], :operatingsystems => os_solaris },
    { :name => 'Jumpstart default PXEGrub', :source => 'jumpstart/PXEGrub.erb', :template_kind => kinds[:PXEGrub], :operatingsystems => os_solaris },
    { :name => "Junos default SLAX", :source => 'ztp/provision.erb', :template_kind => kinds[:provision], :operatingsystems => os_junos },
    { :name => "Junos default ZTP config", :source => 'ztp/ZTP.erb', :template_kind => kinds[:ZTP], :operatingsystems => os_junos },
    { :name => "Junos default finish", :source => 'ztp/finish.erb', :template_kind => kinds[:finish], :operatingsystems => os_junos },
    { :name => 'Kickstart default', :source => 'kickstart/provision.erb', :template_kind => kinds[:provision] },
    { :name => 'Kickstart RHEL default', :source => 'kickstart/provision_rhel.erb', :template_kind => kinds[:provision] },
    { :name => 'Kickstart default finish', :source => 'kickstart/finish.erb', :template_kind => kinds[:finish] },
    { :name => 'Kickstart default PXELinux', :source => 'kickstart/PXELinux.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'Kickstart default PXEGrub', :source => 'kickstart/PXEGrub.erb', :template_kind => kinds[:PXEGrub] },
    { :name => 'Kickstart default PXEGrub2', :source => 'kickstart/PXEGrub2.erb', :template_kind => kinds[:PXEGrub2] },
    { :name => 'Kickstart default iPXE', :source => 'kickstart/iPXE.erb', :template_kind => kinds[:iPXE] },
    { :name => 'Kickstart default user data', :source => 'kickstart/userdata.erb', :template_kind => kinds[:user_data] },
    { :name => 'NX-OS default POAP setup', :source => 'poap/provision.erb', :template_kind => kinds[:POAP] },
    { :name => 'Preseed default', :source => 'preseed/provision.erb', :template_kind => kinds[:provision] },
    { :name => 'Preseed default finish', :source => 'preseed/finish.erb', :template_kind => kinds[:finish] },
    { :name => 'Preseed default PXELinux', :source => 'preseed/PXELinux.erb', :template_kind => kinds[:PXELinux] },
    { :name => 'Preseed default iPXE', :source => 'preseed/iPXE.erb', :template_kind => kinds[:iPXE] },
    { :name => 'Preseed default user data', :source => 'preseed/userdata.erb', :template_kind => kinds[:user_data] },
    { :name => 'UserData default', :source => 'cloudinit/userdata_cloudinit.erb', :template_kind => kinds[:user_data] },
    { :name => 'WAIK default PXELinux', :source => 'waik/PXELinux.erb', :template_kind => kinds[:PXELinux], :operatingsystems => os_windows },
    { :name => 'XenServer default answerfile', :source => 'xenserver/provision.erb', :template_kind => kinds[:provision] },
    { :name => 'XenServer default finish', :source => 'xenserver/finish.erb', :template_kind => kinds[:finish] },
    { :name => 'XenServer default PXELinux', :source => 'xenserver/PXELinux.erb', :template_kind => kinds[:PXELinux] },
    # snippets
    { :name => 'alterator_pkglist', :source => 'snippets/_alterator_pkglist.erb', :snippet => true },
    { :name => 'bmc_nic_setup', :source => 'snippets/_bmc_nic_setup.erb', :snippet => true },
    { :name => 'chef_client', :source => 'snippets/_chef_client.erb', :snippet => true },
    { :name => 'coreos_cloudconfig', :source => 'snippets/_coreos_cloudconfig.erb', :snippet => true },
    { :name => 'epel', :source => 'snippets/_epel.erb', :snippet => true },
    { :name => 'fix_hosts', :source => 'snippets/_fix_hosts.erb', :snippet => true },
    { :name => 'freeipa_register', :source => 'snippets/_freeipa_register.erb', :snippet => true },
    { :name => 'http_proxy', :source => 'snippets/_http_proxy.erb', :snippet => true },
    { :name => 'kickstart_networking_setup', :source => 'snippets/_kickstart_networking_setup.erb', :snippet => true },
    { :name => 'preseed_networking_setup', :source => 'snippets/_preseed_networking_setup.erb', :snippet => true },
    { :name => 'puppet.conf', :source => 'snippets/_puppet.conf.erb', :snippet => true },
    { :name => 'puppet_setup', :source => 'snippets/_puppet_setup.erb', :snippet => true },
    { :name => 'puppetlabs_repo', :source => 'snippets/_puppetlabs_repo.erb', :snippet => true },
    { :name => 'redhat_register', :source => 'snippets/_redhat_register.erb', :snippet => true },
    { :name => 'remote_execution_ssh_keys', :source => 'snippets/_remote_execution_ssh_keys.erb', :snippet => true },
    { :name => 'saltstack_minion', :source => 'snippets/_saltstack_minion.erb', :snippet => true },
    { :name => 'saltstack_setup', :source => 'snippets/_saltstack_setup.erb', :snippet => true },
    { :name => 'pxelinux_chainload', :source => 'snippets/_pxelinux_chainload.erb', :snippet => true },
    { :name => 'pxegrub_chainload', :source => 'snippets/_pxegrub_chainload.erb', :snippet => true },
    { :name => 'pxegrub2_chainload', :source => 'snippets/_pxegrub2_chainload.erb', :snippet => true },
    { :name => 'pxelinux_discovery', :source => 'snippets/_pxelinux_discovery.erb', :snippet => true },
    { :name => 'pxegrub_discovery', :source => 'snippets/_pxegrub_discovery.erb', :snippet => true },
    { :name => 'pxegrub2_discovery', :source => 'snippets/_pxegrub2_discovery.erb', :snippet => true }
  ].each do |input|
    contents = File.read(File.join("#{Rails.root}/app/views/unattended", input.delete(:source)))

    if (t = ProvisioningTemplate.unscoped.find_by_name(input[:name])) && !SeedHelper.audit_modified?(ProvisioningTemplate, input[:name])
      next if t.global_default?

      if t.template != contents
        t.template = contents
        raise "Unable to update template #{t.name}: #{format_errors t}" unless t.save
      end
    else
      next if SeedHelper.audit_modified? ProvisioningTemplate, input[:name]
      input.merge!(:default => true)

      t = ProvisioningTemplate.create({
        :snippet  => false,
        :template => contents
      }.merge(input))

      if t.default?
        t.organizations = organizations if SETTINGS[:organizations_enabled]
        t.locations = locations if SETTINGS[:locations_enabled]
      end
      raise "Unable to create template #{t.name}: #{format_errors t}" if t.nil? || t.errors.any?
    end
  end
end
