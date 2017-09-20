class ProvisioningTemplatesList
  class << self
    def seeded_templates
      [
        # Generic PXE files
        { :name => 'PXELinux global default', :source => 'PXELinux/pxelinux_global_default.erb', :template_kind => kinds[:PXELinux] },
        { :name => 'PXEGrub global default', :source => 'PXEGrub/pxegrub_global_default.erb', :template_kind => kinds[:PXEGrub] },
        { :name => 'PXEGrub2 global default', :source => 'PXEGrub2/pxegrub2_global_default.erb', :template_kind => kinds[:PXEGrub2] },
        { :name => 'PXELinux default local boot', :source => 'PXELinux/pxelinux_default_local_boot.erb', :template_kind => kinds[:PXELinux] },
        { :name => 'PXEGrub default local boot', :source => 'PXEGrub/pxegrub_default_local_boot.erb', :template_kind => kinds[:PXEGrub] },
        { :name => 'PXEGrub2 default local boot', :source => 'PXEGrub2/pxegrub2_default_local_boot.erb', :template_kind => kinds[:PXEGrub2] },
        { :name => 'PXELinux default memdisk', :source => 'PXELinux/pxelinux_default_memdisk.erb', :template_kind => kinds[:PXELinux] },
        { :name => 'PXELinux chain iPXE', :source => 'PXELinux/pxelinux_chain_ipxe.erb', :template_kind => kinds[:PXELinux] },
        { :name => 'PXELinux chain iPXE UNDI', :source => 'PXELinux/pxelinux_chain_ipxe_undi.erb', :template_kind => kinds[:PXELinux] },
        # OS specific files
        { :name => 'Alterator default', :source => 'provision/alterator_default.erb', :template_kind => kinds[:provision] },
        { :name => 'Alterator default finish', :source => 'finish/alterator_default_finish.erb', :template_kind => kinds[:finish] },
        { :name => 'Alterator default PXELinux', :source => 'PXELinux/alterator_default_pxelinux.erb', :template_kind => kinds[:PXELinux] },
        { :name => 'Atomic Kickstart default', :source => 'provision/atomic_kickstart_default.erb', :template_kind => kinds[:provision] },
        { :name => 'AutoYaST default', :source => 'provision/autoyast_default.erb', :template_kind => kinds[:provision], :operatingsystems => os_suse },
        { :name => 'AutoYaST SLES default', :source => 'provision/autoyast_sles_default.erb', :template_kind => kinds[:provision], :operatingsystems => os_suse },
        { :name => 'AutoYaST default PXELinux', :source => 'PXELinux/autoyast_default_pxelinux.erb', :template_kind => kinds[:PXELinux], :operatingsystems => os_suse },
        { :name => 'AutoYaST default iPXE', :source => 'iPXE/autoyast_default_ipxe.erb', :template_kind => kinds[:iPXE] },
        { :name => 'AutoYaST default user data', :source => 'user_data/autoyast_default_user_data.erb', :template_kind => kinds[:user_data] },
        { :name => 'CoreOS provision', :source => 'provision/coreos_provision.erb', :template_kind => kinds[:provision]},
        { :name => 'CoreOS PXELinux', :source => 'PXELinux/coreos_pxelinux.erb', :template_kind => kinds[:PXELinux]},
        { :name => 'FreeBSD (mfsBSD) finish', :source => 'finish/freebsd_(mfsbsd)_finish.erb', :template_kind => kinds[:finish] },
        { :name => 'FreeBSD (mfsBSD) provision', :source => 'provision/freebsd_(mfsbsd)_provision.erb', :template_kind => kinds[:provision] },
        { :name => 'FreeBSD (mfsBSD) PXELinux', :source => 'PXELinux/freebsd_(mfsbsd)_pxelinux.erb', :template_kind => kinds[:PXELinux] },
        { :name => 'Grubby default', :source => 'script/grubby_default.erb', :template_kind => kinds[:script] },
        { :name => 'Jumpstart default', :source => 'provision/jumpstart_default.erb', :template_kind => kinds[:provision], :operatingsystems => os_solaris },
        { :name => 'Jumpstart default finish', :source => 'finish/jumpstart_default_finish.erb', :template_kind => kinds[:finish], :operatingsystems => os_solaris },
        { :name => 'Jumpstart default PXEGrub', :source => 'PXEGrub/jumpstart_default_pxegrub.erb', :template_kind => kinds[:PXEGrub], :operatingsystems => os_solaris },
        { :name => "Junos default SLAX", :source => 'provision/junos_default_slax.erb', :template_kind => kinds[:provision], :operatingsystems => os_junos },
        { :name => "Junos default ZTP config", :source => 'ZTP/junos_default_ztp_config.erb', :template_kind => kinds[:ZTP], :operatingsystems => os_junos },
        { :name => "Junos default finish", :source => 'finish/junos_default_finish.erb', :template_kind => kinds[:finish], :operatingsystems => os_junos },
        { :name => 'Kickstart default', :source => 'provision/kickstart_default.erb', :template_kind => kinds[:provision] },
        { :name => 'Kickstart RHEL default', :source => 'provision/kickstart_rhel_default.erb', :template_kind => kinds[:provision] },
        { :name => 'Kickstart default finish', :source => 'finish/kickstart_default_finish.erb', :template_kind => kinds[:finish] },
        { :name => 'Kickstart default PXELinux', :source => 'PXELinux/kickstart_default_pxelinux.erb', :template_kind => kinds[:PXELinux] },
        { :name => 'Kickstart default PXEGrub', :source => 'PXEGrub/kickstart_default_pxegrub.erb', :template_kind => kinds[:PXEGrub] },
        { :name => 'Kickstart default PXEGrub2', :source => 'PXEGrub2/kickstart_default_pxegrub2.erb', :template_kind => kinds[:PXEGrub2] },
        { :name => 'Kickstart default iPXE', :source => 'iPXE/kickstart_default_ipxe.erb', :template_kind => kinds[:iPXE] },
        { :name => 'Kickstart default user data', :source => 'user_data/kickstart_default_user_data.erb', :template_kind => kinds[:user_data] },
        { :name => 'NX-OS default POAP setup', :source => 'POAP/nx-os_default_poap_setup.erb', :template_kind => kinds[:POAP] },
        { :name => 'Preseed default', :source => 'provision/preseed_default.erb', :template_kind => kinds[:provision] },
        { :name => 'Preseed default finish', :source => 'finish/preseed_default_finish.erb', :template_kind => kinds[:finish] },
        { :name => 'Preseed default PXELinux', :source => 'PXELinux/preseed_default_pxelinux.erb', :template_kind => kinds[:PXELinux] },
        { :name => 'Preseed default PXEGrub2', :source => 'PXEGrub2/preseed_default_pxegrub2.erb', :template_kind => kinds[:PXEGrub2] },
        { :name => 'Preseed default iPXE', :source => 'iPXE/preseed_default_ipxe.erb', :template_kind => kinds[:iPXE] },
        { :name => 'Preseed default user data', :source => 'user_data/preseed_default_user_data.erb', :template_kind => kinds[:user_data] },
        { :name => 'UserData default', :source => 'user_data/userdata_default.erb', :template_kind => kinds[:user_data] },
        { :name => 'WAIK default PXELinux', :source => 'PXELinux/waik_default_pxelinux.erb', :template_kind => kinds[:PXELinux], :operatingsystems => os_windows },
        { :name => 'XenServer default answerfile', :source => 'provision/xenserver_default_answerfile.erb', :template_kind => kinds[:provision] },
        { :name => 'XenServer default finish', :source => 'finish/xenserver_default_finish.erb', :template_kind => kinds[:finish] },
        { :name => 'XenServer default PXELinux', :source => 'PXELinux/xenserver_default_pxelinux.erb', :template_kind => kinds[:PXELinux] },
        # snippets
        { :name => 'ansible_tower_callback_service', :source => 'snippet/_ansible_tower_callback_service.erb', :snippet => true },
        { :name => 'alterator_pkglist', :source => 'snippet/_alterator_pkglist.erb', :snippet => true },
        { :name => 'bmc_nic_setup', :source => 'snippet/_bmc_nic_setup.erb', :snippet => true },
        { :name => 'chef_client', :source => 'snippet/_chef_client.erb', :snippet => true },
        { :name => 'coreos_cloudconfig', :source => 'snippet/_coreos_cloudconfig.erb', :snippet => true },
        { :name => 'create_users', :source => 'snippet/_create_users.erb', :snippet => true },
        { :name => 'epel', :source => 'snippet/_epel.erb', :snippet => true },
        { :name => 'fix_hosts', :source => 'snippet/_fix_hosts.erb', :snippet => true },
        { :name => 'freeipa_register', :source => 'snippet/_freeipa_register.erb', :snippet => true },
        { :name => 'http_proxy', :source => 'snippet/_http_proxy.erb', :snippet => true },
        { :name => 'kickstart_ifcfg_bond_interface', :source => 'snippet/_kickstart_ifcfg_bond_interface.erb', :snippet => true },
        { :name => 'kickstart_ifcfg_bonded_interface', :source => 'snippet/_kickstart_ifcfg_bonded_interface.erb', :snippet => true },
        { :name => 'kickstart_ifcfg_generic_interface', :source => 'snippet/_kickstart_ifcfg_generic_interface.erb', :snippet => true },
        { :name => 'kickstart_ifcfg_get_identifier_names', :source => 'snippet/_kickstart_ifcfg_get_identifier_names.erb', :snippet => true },
        { :name => 'kickstart_networking_setup', :source => 'snippet/_kickstart_networking_setup.erb', :snippet => true },
        { :name => 'preseed_networking_setup', :source => 'snippet/_preseed_networking_setup.erb', :snippet => true },
        { :name => 'puppet.conf', :source => 'snippet/_puppet.conf.erb', :snippet => true },
        { :name => 'puppet_setup', :source => 'snippet/_puppet_setup.erb', :snippet => true },
        { :name => 'puppetlabs_repo', :source => 'snippet/_puppetlabs_repo.erb', :snippet => true },
        { :name => 'pxegrub2_chainload', :source => 'snippet/_pxegrub2_chainload.erb', :snippet => true },
        { :name => 'pxegrub2_discovery', :source => 'snippet/_pxegrub2_discovery.erb', :snippet => true },
        { :name => 'pxegrub_chainload', :source => 'snippet/_pxegrub_chainload.erb', :snippet => true },
        { :name => 'pxegrub_discovery', :source => 'snippet/_pxegrub_discovery.erb', :snippet => true },
        { :name => 'pxelinux_chainload', :source => 'snippet/_pxelinux_chainload.erb', :snippet => true },
        { :name => 'pxelinux_discovery', :source => 'snippet/_pxelinux_discovery.erb', :snippet => true },
        { :name => 'redhat_register', :source => 'snippet/_redhat_register.erb', :snippet => true },
        { :name => 'remote_execution_ssh_keys', :source => 'snippet/_remote_execution_ssh_keys.erb', :snippet => true },
        { :name => 'saltstack_minion', :source => 'snippet/_saltstack_minion.erb', :snippet => true },
        { :name => 'saltstack_setup', :source => 'snippet/_saltstack_setup.erb', :snippet => true }
      ]
    end

    def kinds
      kinds = {}
      TemplateKind.default_template_labels.keys.map(&:to_sym).each do |type|
        kinds[type] = TemplateKind.unscoped.find_by_name(type)
        kinds[type] ||= TemplateKind.unscoped.create(:name => type)
        raise "Unable to create template kind: #{format_errors kinds[type]}" if kinds[type].nil? || kinds[type].errors.any?
      end
      kinds
    end

    def os_junos
      Operatingsystem.where(:type => "Junos") || Operatingsystem.where("name LIKE ?", "junos")
    end

    def os_solaris
      Operatingsystem.where(:type => "Solaris")
    end

    def os_suse
      Operatingsystem.where(:type => "Suse") || Operatingsystem.where("name LIKE ?", "suse")
    end

    def os_windows
      Operatingsystem.where(:type => "Windows")
    end
  end
end
