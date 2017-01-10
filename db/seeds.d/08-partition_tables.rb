# Partition tables
organizations = Organization.unscoped.all
locations = Location.unscoped.all
Ptable.without_auditing do
  [
    { :name => 'AutoYaST entire SCSI disk', :os_family => 'Suse', :source => 'autoyast/disklayout_scsi.erb' },
    { :name => 'AutoYaST entire virtual disk', :os_family => 'Suse', :source => 'autoyast/disklayout_virtual.erb' },
    { :name => 'AutoYaST LVM', :os_family => 'Suse', :source => 'autoyast/disklayout_lvm.erb' },
    { :name => 'CoreOS default fake', :os_family => 'Coreos', :source => 'coreos/disklayout_CoreOS.erb' },
    { :name => 'FreeBSD', :os_family => 'Freebsd', :source => 'freebsd/disklayout_FreeBSD_mfsBSD.erb' },
    { :name => 'Jumpstart default', :os_family => 'Solaris', :source => 'jumpstart/disklayout.erb' },
    { :name => 'Jumpstart mirrored', :os_family => 'Solaris', :source => 'jumpstart/disklayout_mirrored.erb' },
    { :name => 'Junos default fake', :os_family => 'Junos', :source => 'ztp/disklayout.erb' },
    { :name => 'Kickstart default', :os_family => 'Redhat', :source => 'kickstart/disklayout.erb' },
    { :name => 'NX-OS default fake', :os_family => 'NXOS', :source => 'poap/disklayout.erb' },
    { :name => 'Preseed default', :os_family => 'Debian', :source => 'preseed/disklayout.erb' },
    { :name => 'Preseed custom LVM', :os_family => 'Debian', :source => 'preseed/disklayout_lvm.erb' },
    { :name => 'XenServer default', :os_family => 'Xenserver', :source => 'xenserver/disklayout.erb' }
  ].each do |input|
    contents = File.read(File.join("#{Rails.root}/app/views/unattended", input.delete(:source)))

    if (p = Ptable.unscoped.find_by_name(input[:name])) && !SeedHelper.audit_modified?(Ptable, input[:name])
      if p.layout != contents
        p.layout = contents
        raise "Unable to update partition table: #{format_errors p}" unless p.save
      end
    else
      next if SeedHelper.audit_modified? Ptable, input[:name]
      p = Ptable.create({
        :layout => contents
      }.merge(input.merge(:default => true)))

      if p.default?
        p.organizations = organizations if SETTINGS[:organizations_enabled]
        p.locations = locations if SETTINGS[:locations_enabled]
      end
      raise "Unable to create partition table: #{format_errors p}" if p.nil? || p.errors.any?
    end
  end
end
