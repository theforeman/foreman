SEEDED_PARTITION_TABLES = [
  {:name => 'AutoYaST entire SCSI disk', :os_family => 'Suse', :source => 'autoyast/disklayout_scsi.erb'},
  {:name => 'AutoYaST entire virtual disk', :os_family => 'Suse', :source => 'autoyast/disklayout_virtual.erb'},
  {:name => 'AutoYaST LVM', :os_family => 'Suse', :source => 'autoyast/disklayout_lvm.erb'},
  {:name => 'CoreOS default fake', :os_family => 'Coreos', :source => 'coreos/disklayout_CoreOS.erb'},
  {:name => 'FreeBSD', :os_family => 'Freebsd', :source => 'freebsd/disklayout_FreeBSD_mfsBSD.erb'},
  {:name => 'Jumpstart default', :os_family => 'Solaris', :source => 'jumpstart/disklayout.erb'},
  {:name => 'Jumpstart mirrored', :os_family => 'Solaris', :source => 'jumpstart/disklayout_mirrored.erb'},
  {:name => 'Junos default fake', :os_family => 'Junos', :source => 'ztp/disklayout.erb'},
  {:name => 'Kickstart default', :os_family => 'Redhat', :source => 'kickstart/disklayout.erb'},
  {:name => 'NX-OS default fake', :os_family => 'NXOS', :source => 'poap/disklayout.erb'},
  {:name => 'Preseed default', :os_family => 'Debian', :source => 'preseed/disklayout.erb'},
  {:name => 'Preseed custom LVM', :os_family => 'Debian', :source => 'preseed/disklayout_lvm.erb'},
  {:name => 'XenServer default', :os_family => 'Xenserver', :source => 'xenserver/disklayout.erb'}
]
