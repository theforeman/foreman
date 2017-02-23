SEEDED_PARTITION_TABLES = [
  {:name => 'AutoYaST entire SCSI disk', :os_family => 'Suse', :source => 'autoyast_entire_scsi_disk.erb'},
  {:name => 'AutoYaST entire virtual disk', :os_family => 'Suse', :source => 'autoyast_entire_virtual_disk.erb'},
  {:name => 'AutoYaST LVM', :os_family => 'Suse', :source => 'autoyast_lvm.erb'},
  {:name => 'CoreOS default fake', :os_family => 'Coreos', :source => 'coreos_default_fake.erb'},
  {:name => 'FreeBSD', :os_family => 'Freebsd', :source => 'freebsd_default_fake.erb'},
  {:name => 'Jumpstart default', :os_family => 'Solaris', :source => 'jumpstart_default.erb'},
  {:name => 'Jumpstart mirrored', :os_family => 'Solaris', :source => 'jumpstart_mirrored.erb'},
  {:name => 'Junos default fake', :os_family => 'Junos', :source => 'junos_default_fake.erb'},
  {:name => 'Kickstart default', :os_family => 'Redhat', :source => 'kickstart_default.erb'},
  {:name => 'NX-OS default fake', :os_family => 'NXOS', :source => 'nx-os_default_fake.erb'},
  {:name => 'Preseed default', :os_family => 'Debian', :source => 'preseed_default.erb'},
  {:name => 'Preseed custom LVM', :os_family => 'Debian', :source => 'preseed_default_lvm.erb'},
  {:name => 'XenServer default', :os_family => 'Xenserver', :source => 'xenserver_default.erb'}
]
