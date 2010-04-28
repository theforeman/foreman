%define name foreman
%define homedir /usr/share/%{name}
%define confdir extras/spec

Name:           %{name}
Version:        0.1.4
Release:        3%{?dist}
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
Requires:       puppet >= 0.24.4
Requires:       rubygem(sqlite3-ruby)
Packager:       Ohad Levy <ohadlevy@gmail.com>

%description
Foreman is aimed to be a Single Address For All Machines Life Cycle Management.
Foreman is based on Ruby on Rails, and this package bundle all Rails and plugins required for Foreman to work

%prep
%setup -q -n %{name}

%build

%install
%{__rm} -rf %{buildroot}
%{__install} -p -d -m0755 %{buildroot}%{_datadir}/%{name}
%{__install} -p -d -m0755 %{buildroot}%{_defaultdocdir}/%{name}-%{version}
%{__install} -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/%{name}
%{__install} -Dp -m0755 %{confdir}/%{name}.init %{buildroot}%{_initrddir}/%{name}
%{__cp} -p -r app config db extras lib public Rakefile script vendor %{buildroot}%{_datadir}/%{name}
%{__chmod} a+x %{buildroot}%{_datadir}/%{name}/script/{console,dbconsole,runner}
%{__rm} -rf %{buildroot}%{_datadir}/%{name}/extras/{jumpstart,spec,puppet}
%{__rm} -rf %{buildroot}%{_datadir}/%{name}/VERSION
%{__mkdir} %{buildroot}%{_datadir}/%{name}/{tmp,log}

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,0755)
%{_datadir}/%{name}
%doc README
%{_initrddir}/foreman
%config(noreplace) %{homedir}/config/settings.yaml
%config(noreplace) %{homedir}/config/database.yml
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}

%pre
# Add the "foreman" user and group
/usr/sbin/useradd -c "Foreman" -s /sbin/nologin -r -d %{homedir} -G puppet %{name} 2> /dev/null || :

%post
# fixing some permissions issues and file duplication warning while creating the RPM.
for dir in db tmp log public config/environment.rb; do
  /bin/chown -R foreman:root %{homedir}/$dir
done
/bin/chown foreman:root %{homedir}
/bin/chown -R root:root %{homedir}/db/migrate

# install foreman (but don't activate)
/sbin/chkconfig --add %{name}

# migrate the SQLite database
su - foreman -s /bin/bash -c 'cd ; /usr/bin/rake db:migrate RAILS_ENV=production > /dev/null'

%changelog
* Thu Apr 19 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1-4-3
- added status to startup script
- removed puppet module from the RPM
* Thu Apr 12 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1-4-2
- Added startup script for built in webrick server
- Changed foreman user default shell to /sbin/nologin and is now part of the puppet group
- defaults to sqlite database
* Thu Apr 6 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1-4-1
- Initial release.
