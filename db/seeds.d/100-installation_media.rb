organizations = Organization.unscoped.all
locations = Location.unscoped.all
os_suse = Operatingsystem.unscoped.where(:type => "Suse") || Operatingsystem.unscoped.where("name LIKE ?", "suse")

# Installation media: default mirrors
Medium.without_auditing do
  [
    {
      :name => "CentOS 7 mirror",
      :os_family => "Redhat",
      :path => "http://mirror.centos.org/centos/$major/os/$arch",
    },
    {
      :name => "CentOS Stream",
      :os_family => "Redhat",
      :path => "http://mirror.centos.org/centos/$major-stream/BaseOS/$arch/os",
    },
    {
      :name => "CentOS Stream 9 mirror",
      :os_family => "Redhat",
      :path => "http://mirror.stream.centos.org/$major-stream/BaseOS/$arch/os",
    },
    {
      :name => "Debian mirror",
      :os_family => "Debian",
      :path => "http://ftp.debian.org/debian",
    },
    {
      :name => "Fedora mirror",
      :os_family => "Redhat",
      :path => "http://dl.fedoraproject.org/pub/fedora/linux/releases/$major/Server/$arch/os/",
    },
    {
      :name => "FreeBSD mirror",
      :os_family => "Freebsd",
      :path => "http://ftp.freebsd.org/pub/FreeBSD/releases/$arch/$version-RELEASE/",
    },
    {
      :name => "OpenSUSE mirror",
      :os_family => "Suse",
      :path => "http://download.opensuse.org/distribution/leap/$version/repo/oss", :operatingsystems => os_suse
    },
    {
      :name => "Ubuntu mirror",
      :os_family => "Debian",
      :path => "http://archive.ubuntu.com/ubuntu",
      :boot_path => "https://releases.ubuntu.com",
    },
    {
      :name => "RancherOS mirror",
      :os_family => "Rancheros",
      :path => "https://github.com/rancher/os/releases/download/v$version",
    },
    {
      :name => "Rocky Linux",
      :os_family => "Redhat",
      :path => "https://download.rockylinux.org/pub/rocky/$version/BaseOS/$arch/os",
    },
    {
      :name => "AlmaLinux",
      :os_family => "Redhat",
      :path => "https://repo.almalinux.org/almalinux/$version/BaseOS/$arch/os/",
    },
    {
      :name => "CoreOS mirror",
      :os_family => "Coreos",
      :path => "http://$release-temporary-archive.release.core-os.net",
    },
    {
      :name => "Flatcar mirror",
      :os_family => "Coreos",
      :path => "http://$release.release.flatcar-linux.net",
    },
    {
      :name => "Fedora CoreOS mirror",
      :os_family => "Fcos",
      :path => "https://builds.coreos.fedoraproject.org",
    },
    {
      :name => "Red Hat CoreOS mirror",
      :os_family => "Rhcos",
      :path => "http://mirror.openshift.com",
    },
  ].each do |input|
    if input[:name] == 'Ubuntu mirror'
      seeded_medium = Medium.unscoped.find_by(name: input[:name], path: input[:path])
      if seeded_medium && seeded_medium.boot_path.blank? && !SeedHelper.audit_modified?(Medium, input[:name])
        seeded_medium.update_column(:boot_path, input[:boot_path])
      end
    end
    next if Medium.unscoped.where(['name = ? OR path = ?', input[:name], input[:path]]).any?
    next if SeedHelper.audit_modified? Medium, input[:name]
    m = Medium.create input
    m.organizations = organizations
    m.locations = locations
    raise "Unable to create medium: #{SeedHelper.format_errors m}" if m.nil? || m.errors.any?
  end
end
