# Partition tables
Ptable.without_auditing do
  [
    { :name => 'AutoYaST entire SCSI disk', :os_family => 'Suse', :source => 'autoyast/disklayout_scsi.erb' },
    { :name => 'AutoYaST entire virtual disk', :os_family => 'Suse', :source => 'autoyast/disklayout_virtual.erb' },
    { :name => 'AutoYaST LVM', :os_family => 'Suse', :source => 'autoyast/disklayout_lvm.erb' },
    { :name => 'FreeBSD', :os_family => 'Freebsd', :source => 'freebsd/disklayout_FreeBSD_mfsBSD.erb' },
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
