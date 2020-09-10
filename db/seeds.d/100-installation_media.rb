organizations = Organization.unscoped.all
locations = Location.unscoped.all
os_suse = Operatingsystem.unscoped.where(:type => "Suse") || Operatingsystem.unscoped.where("name LIKE ?", "suse")

# Installation media: default mirrors
Medium.without_auditing do
  [
    { :name => "CentOS 7 mirror",      :os_family => "Redhat",  :path => "http://mirror.centos.org/centos/$major/os/$arch" },
    { :name => "CentOS 8 mirror",      :os_family => "Redhat",  :path => "http://mirror.centos.org/centos/$major/BaseOS/$arch/kickstart" },
    { :name => "Debian mirror",        :os_family => "Debian",  :path => "http://ftp.debian.org/debian" },
    { :name => "Fedora mirror",        :os_family => "Redhat",  :path => "http://dl.fedoraproject.org/pub/fedora/linux/releases/$major/Server/$arch/os/" },
    { :name => "Fedora Atomic mirror", :os_family => "Redhat",  :path => "http://dl.fedoraproject.org/pub/alt/atomic/stable/Cloud_Atomic/$arch/os/" },
    { :name => "FreeBSD mirror",       :os_family => "Freebsd", :path => "http://ftp.freebsd.org/pub/FreeBSD/releases/$arch/$version-RELEASE/" },
    { :name => "OpenSUSE mirror",      :os_family => "Suse",    :path => "http://download.opensuse.org/distribution/leap/$version/repo/oss", :operatingsystems => os_suse },
    { :name => "Ubuntu mirror",        :os_family => "Debian",  :path => "http://archive.ubuntu.com/ubuntu" },
    { :name => "CoreOS mirror",        :os_family => "Coreos",  :path => "http://$release.release.core-os.net" },
    { :name => "Flatcar mirror",       :os_family => "Coreos",  :path => "http://$release.release.flatcar-linux.net" },
    { :name => "RancherOS mirror", :os_family => "Rancheros", :path => "https://github.com/rancher/os/releases/download/v$version" },
  ].each do |input|
    next if Medium.unscoped.where(['name = ? OR path = ?', input[:name], input[:path]]).any?
    next if SeedHelper.audit_modified? Medium, input[:name]
    m = Medium.create input
    m.organizations = organizations
    m.locations = locations
    raise "Unable to create medium: #{format_errors m}" if m.nil? || m.errors.any?
  end
end
