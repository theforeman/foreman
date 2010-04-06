%define name foreman
%define homedir /usr/share/%{name}

Name:           %{name}
Version:        0.1.4
Release:        1%{?dist}
Summary:        Systems Management web application
Group:          Administration Tools
License:        GPLv2+
URL:            http://theforeman.org
Source0:        http://github.com/ohadlevy/foreman/tarball/foreman-0.1-4.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       ruby(abi) = 1.8
Requires:       rubygems
Requires:       rubygem(rack) >= 1.0.1
Requires:       rubygem(rake) >= 0.8.3
Packager:       Ohad Levy <ohadlevy@gmail.com>


%description
Foreman is aimed to be a Single Address For All Machines Life Cycle Management.
    * Foreman integrates with Puppet (and acts as web front end to it).
    * Foreman takes care of bare bone provisioning until the point puppet is running, allowing Puppet to do what it does best.
    * Foreman shows you Systems Inventory (based on Facter) and provides real time information about hosts status based on Puppet reports.
    * Foreman creates everything you need when adding a new machine to your network,It's goal being automatically managing 
      everything you would normally manage manually - that would eventually include DNS, DHCP, TFTP, PuppetCA, CMDB and 
      everything else you might consider useful.
    * With Foreman You Can Always Rebuild Your Machines From Scratch!
    * Foreman is designed to work in a large enterprise, where multiple domains, subnets and puppetmasters are required. 
      In many cases, Foreman could help remote provisions where no experienced technicians are available.

Foreman is based on Ruby on Rails, and this package bundle all Rails and plugins required for Foreman to work

%prep
%setup -q -n %{name}

%build

%install
%{__rm} -rf %{buildroot}
%{__install} -p -d -m0755 %{buildroot}%{_datadir}/%{name}
%{__install} -p -d -m0755 %{buildroot}%{_datadir}/%{name}/vendor
%{__install} -p -d -m0755 %{buildroot}%{_defaultdocdir}/%{name}-%{version}
%{__cp} -p -r app config db extras lib public Rakefile script vendor %{buildroot}%{_datadir}/%{name}

chmod a+x %{buildroot}%{_datadir}/%{name}/script/{console,dbconsole,runner} 

%{__rm} -rf %{buildroot}%{_datadir}/%{name}/extras/jumpstart


%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,0755)
%{_datadir}/%{name}
%doc README VERSION
%config(noreplace) %{homedir}/config/settings.yaml
%config(noreplace) %{homedir}/config/database.yml
%attr(775,foreman,root) %{homedir}
%attr(775,foreman,root) %{homedir}/db
%attr(775,root,root) %{homedir}/db/migrate
%attr(775,foreman,root) %{homedir}/public
%attr(775,foreman,root) %{homedir}/config/environment.rb

%pre
# Add the "foreman" user and group
# we need a shell to be able to use su - later
/usr/sbin/useradd -c "Foreman" -s /bin/false -r -d %{homedir} %{name} 2> /dev/null || :


%changelog
* Thu Apr 6 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1-4-1
- Initial release.
