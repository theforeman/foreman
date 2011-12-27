%global homedir %{_datadir}/%{name}
%global confdir extras/spec

Name:           foreman
Version:        0.4.1
Release:        0.1
Summary:        Systems Management web application

Group:          Applications/System
License:        GPLv3+
URL:            http://theforeman.org
Source0:        http://github.com/ohadlevy/%{name}/tarball/%{name}-%{version}.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:      noarch

Requires:       ruby(abi) = 1.8
Requires:       rubygems
Requires:       rubygem(rake) >= 0.8.3
Requires:       puppet >= 0.24.4
Requires:       rubygem(sqlite3-ruby)
Requires:       rubygem(rest-client)
Requires:       rubygem(json)
Requires(pre):  shadow-utils
Requires(post): chkconfig
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(postun): initscripts

%description
Foreman is aimed to be a Single Address For All Machines Life Cycle Management.
Foreman is based on Ruby on Rails, and this package bundles Rails and all
plugins required for Foreman to work.

%prep
%setup -q -n %{name}

%build

%install
rm -rf %{buildroot}
install -d -m0755 %{buildroot}%{_datadir}/%{name}
install -d -m0755 %{buildroot}%{_sysconfdir}/%{name}
install -d -m0755 %{buildroot}%{_localstatedir}/lib/%{name}
install -d -m0755 %{buildroot}%{_localstatedir}/run/%{name}
install -d -m0750 %{buildroot}%{_localstatedir}/log/%{name}

install -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0755 %{confdir}/%{name}.init %{buildroot}%{_initrddir}/%{name}
install -Dp -m0644 %{confdir}/logrotate %{buildroot}%{_sysconfdir}/logrotate.d/%{name}
cp -p -r app config extras lib Rakefile script vendor %{buildroot}%{_datadir}/%{name}
chmod a+x %{buildroot}%{_datadir}/%{name}/script/{console,dbconsole,runner}
rm -rf %{buildroot}%{_datadir}/%{name}/extras/{jumpstart,spec}
rm -rf %{buildroot}%{_datadir}/%{name}/VERSION
# remove all test units from productive release
find %{buildroot}%{_datadir}/%{name} -type d -name "test" |xargs rm -rf

# Move config files to %{_sysconfdir}
mv %{buildroot}%{_datadir}/%{name}/config/email.yaml.example %{buildroot}%{_datadir}/%{name}/config/email.yaml
for i in database.yml email.yaml settings.yaml; do
    mv %{buildroot}%{_datadir}/%{name}/config/$i %{buildroot}%{_sysconfdir}/%{name}
    ln -sv %{_sysconfdir}/%{name}/$i %{buildroot}%{_datadir}/%{name}/config/$i
done

# Put db in %{_localstatedir}/lib/%{name}/db
cp -pr db/migrate %{buildroot}%{_datadir}/%{name}
mkdir %{buildroot}%{_localstatedir}/lib/%{name}/db

ln -sv %{_localstatedir}/lib/%{name}/db %{buildroot}%{_datadir}/%{name}/db
ln -sv %{_datadir}/%{name}/migrate %{buildroot}%{_localstatedir}/lib/%{name}/db/migrate

# Put HTML %{_localstatedir}/lib/%{name}/public
cp -pr public %{buildroot}%{_localstatedir}/lib/%{name}/
ln -sv %{_localstatedir}/lib/%{name}/public %{buildroot}%{_datadir}/%{name}/public

# Put logs in %{_localstatedir}/log/%{name}
ln -sv %{_localstatedir}/log/%{name} %{buildroot}%{_datadir}/%{name}/log

# Put tmp files in %{_localstatedir}/run/%{name}
ln -sv %{_localstatedir}/run/%{name} %{buildroot}%{_datadir}/%{name}/tmp

# Create a script for migrating the database
cat << \EOF > %{buildroot}%{_datadir}/%{name}/extras/dbmigrate
#!/bin/sh
cd && /usr/bin/rake db:migrate RAILS_ENV=production
EOF
chmod a+x %{buildroot}%{_datadir}/%{name}/extras/dbmigrate

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,0755)
%doc README
%{_datadir}/%{name}
%{_initrddir}/%{name}
%config(noreplace) %{_sysconfdir}/%{name}
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
%attr(-,%{name},%{name}) %{_datadir}/%{name}/config/environment.rb
%attr(-,%{name},%{name}) %{_localstatedir}/lib/%{name}
%attr(-,%{name},%{name}) %{_localstatedir}/log/%{name}
%attr(-,%{name},%{name}) %{_localstatedir}/run/%{name}

%pre
# Add the "foreman" user and group
getent group %{name} >/dev/null || groupadd -r %{name}
getent passwd %{name} >/dev/null || \
    useradd -r -g %{name} -G puppet -d %{homedir} -s /sbin/nologin -c "Foreman" %{name}
exit 0

%pretrans
# Try to handle upgrades from earlier packages. Replacing a directory with a
# symlink is hampered in rpm by cpio limitations.
datadir=%{_datadir}/%{name}
varlibdir=%{_localstatedir}/lib/%{name}
# remove all active_scaffold left overs
find $datadir -type d -name "active_scaffold*" 2>/dev/null | xargs rm -rf
rm -f $datadir/public/javascripts/all.js 2>/dev/null

if [ ! -d $varlibdir/db -a -d $datadir/db -a ! -L $datadir/db ]; then
  [ -d $varlibdir ] || mkdir -p $varlibdir
  mv $datadir/db $varlibdir/db && ln -s $varlibdir/db $datadir/db
  if [ -d $varlibdir/db/migrate -a ! -L $varlibdir/db/migrate -a ! -d $datadir/migrate ]; then
    mv $varlibdir/db/migrate $datadir/migrate && ln -s $datadir/migrate $varlibdir/db/migrate
  fi
fi

if [ ! -d $varlibdir/public -a -d $datadir/public -a ! -L $datadir/public ]; then
  [ -d $varlibdir ] || mkdir -p $varlibdir
  mv $datadir/public $varlibdir/public && ln -s $varlibdir/public $datadir/public
fi

varlibdir=%{_localstatedir}/log # /var/log
if [ ! -d $varlibdir/%{name} -a -d $datadir/log -a ! -L $datadir/log ]; then
  [ -d $varlibdir ] || mkdir -p $varlibdir
  mv $datadir/log $varlibdir/%{name} && ln -s $varlib/%{name} $datadir/log
fi

varlibdir=%{_localstatedir}/run # /var/run
if [ ! -d $varlibdir/%{name} -a -d $datadir/tmp -a ! -L $datadir/tmp ]; then
  [ -d $varlibdir ] || mkdir -p $varlibdir
  mv $datadir/tmp $varlibdir/%{name} && ln -s $varlib/%{name} $datadir/tmp
fi

%post
/sbin/chkconfig --add %{name} || ::

# initialize/migrate the database (defaults to SQLITE3)
su - foreman -s /bin/bash -c %{_datadir}/%{name}/extras/dbmigrate >/dev/null 2>&1 || :
(/sbin/service foreman status && /sbin/service foreman restart) >/dev/null 2>&1
exit 0

%preun
if [ $1 -eq 0 ] ; then
    /sbin/service %{name} stop >/dev/null 2>&1
    /sbin/chkconfig --del %{name} || :
fi

%postun
if [ $1 -ge 1 ] ; then
    # Restart the service
    /sbin/service %{name} restart >/dev/null 2>&1 || :
fi

%changelog
* Mon Dec 26 2011 ohadlevy@gmail.com - 0.4.1
- rebuilt
* Thu Nov 08 2011 ohadlevy@gmail.com - 0.4
- rebuilt
* Thu Nov 07 2011 ohadlevy@gmail.com - 0.4rc5
- rebuilt
* Thu Oct 25 2011 ohadlevy@gmail.com - 0.4rc4
- rebuilt
* Thu Oct 18 2011 ohadlevy@gmail.com - 0.4rc3
- rebuilt
* Sat Sep 28 2011 ohadlevy@gmail.com - 0.4rc2
- rebuilt
* Sat Sep 10 2011 ohadlevy@gmail.com - 0.4rc1
- rebuilt

* Tue Jun 07 2011 ohadlevy@gmail.com - 0.3
- rebuilt

* Tue May 24 2011 ohadlevy@gmail.com - 0.3rc1-2
- rebuilt

* Thu May 05 2011 ohadlevy@gmail.com - 0.3rc1
- rebuilt

* Tue Mar 29 2011 ohadlevy@gmail.com - 0.2
- Version bump to 0.2

* Tue Mar 22 2011 ohadlevy@gmail.com - 0.2-rc1
- rebuilt

* Thu Feb 24 2011 ohadlevy@gmail.com - 0.1.7-rc5
- rebuilt

* Sat Feb 12 2011 ohadlevy@gmail.com - 0.1.7-rc4.1
- rebuilt
* Mon Jan 31 2011 ohadlevy@gmail.com - 0.1.7-rc3.1
- rebuilt
* Tue Jan 18 2011 ohadlevy@gmail.com - 0.1.7-rc2.1
- rebuilt

* Sat Jan 15 2011 ohadlevy@gmail.com - 0.1.7-rc2
- rebuilt

* Fri Dec 17 2010 ohadlevy@gmail.com - 0.1.7rc1
- rebuilt

* Mon Nov 29 2010 ohadlevy@gmail.com - 0.1.6-3
- rebuilt
* Thu Nov 12 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.6-1
- Included fix for #461, as without it newly installed instances are not usable
* Thu Nov 11 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.6
- New upstream version
* Sun Oct 30 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.6rc2
- New release candidate
- Updated configuration file permssion not to break passenger
* Sun Sep 19 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.6rc1
- Removed the depenecy upon rack 1.0.1 as its now bundled within Foreman
* Mon May 31 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.5-1
- New upstream version
- Added migration support between old directory layout to FHS compliancy, upgrades from 0.1-4.x should now work
- Added support for logrotate
- Cleanup old activescaffold plugin leftovers files
* Fri Apr 30 2010 Todd Zullinger <tmz@pobox.com> - 0.1.4-4
- Rework %%install for better FHS compliance
- Misc. adjustments to match Fedora/EPEL packaging guidelines
- Update License field to GPLv3+ to match README
- Use foreman as the primary group for the foreman user instead of puppet
- This breaks compatibility with previous RPM, as directories can't be replaced with links easily.

* Thu Apr 19 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1-4-3
- added status to startup script
- removed puppet module from the RPM

* Thu Apr 12 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.4-2
- Added startup script for built in webrick server
- Changed foreman user default shell to /sbin/nologin and is now part of the puppet group
- defaults to sqlite database

* Thu Apr 6 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.4-1
- Initial release.
