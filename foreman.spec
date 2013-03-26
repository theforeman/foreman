%global homedir %{_datadir}/%{name}
%global confdir extras/packaging/rpm/sources

Name:   foreman
Version: 1.1stable
Release: 3%{dist}
Summary:Systems Management web application

Group:  Applications/System
License:GPLv3+
URL: http://theforeman.org
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Source0: %{name}-%{version}.tar.gz

BuildArch:  noarch

Requires: ruby(abi) = 1.8
Requires: rubygems
Requires: facter
Requires: puppet >= 0.24.4
Requires: wget
Requires: /etc/cron.d
Requires(pre):  shadow-utils
Requires(post): chkconfig
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(postun): initscripts
Requires: rubygem(json)
Requires: rubygem(rails) = 3.0.20
Requires: rubygem(jquery-rails)
Requires: rubygem(rest-client)
Requires: rubygem(acts_as_audited) = 2.0.0
Requires: rubygem(will_paginate) >= 3.0.2
Requires: rubygem(ancestry) >= 1.3.0
Requires: rubygem(ancestry) < 1.4.0
Requires: rubygem(scoped_search) >= 2.4.0
Requires: rubygem(scoped_search) < 2.5.0
Requires: rubygem(net-ldap)

Requires: rubygem(safemode) >= 1.2.0
Requires: rubygem(safemode) < 1.3.0
Requires: rubygem(uuidtools)
Requires: rubygem(rake) >= 0.9.2.2
Requires: rubygem(ruby_parser) >= 3.0.0
Requires: rubygem(ruby_parser) < 3.1.0
Requires: rubygem(audited-activerecord) >= 3.0.0
Requires: rubygem(rabl) >= 0.7.5
Requires: rubygem(apipie-rails) >= 0.0.13
Requires: rubygem(oauth)
Provides: %{name}-%{version}-%{release}
#Packager:   Ohad Levy <ohadlevy@gmail.com>

%package cli
Summary: Foreman CLI
Group: Applications/System
Requires: %{name}-%{version}-%{release}
Requires: rubygem(foremancli) >= 1.0

%description cli
Meta Package to install rubygem-cli and its dependencies

%files cli

%package release
Summary:        Foreman repository files
Group:  	Applications/System


%description release
Foreman repository contains open source and other distributable software for
Fedora. This package contains the repository configuration for Yum.

%files release
%defattr(-,root,root,-)
%config(noreplace) %{_sysconfdir}/yum.repos.d/*

%package libvirt
Summary: Foreman libvirt support
Group:  Applications/System
Requires: rubygem(virt) >= 0.2.1
Requires: %{name}-%{version}-%{release}
Requires: foreman-ec2-%{version}-%{release}
Obsoletes: foreman-virt

%description libvirt
Meta Package to install requirements for virt support

%files libvirt
%{_datadir}/%{name}/bundler.d/libvirt.rb

%post libvirt
#All the foreman-* rpm's are version locked, and foreman runs this as a posttrans on i
#install/update, so the only time this needs to be run is on install in case someone
#installs it after the initial foreman install.
if [ $1 == 1 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%postun libvirt
#If we uninstall a package then we need to update the bundler config as well. We can no
#longer guarantee the dependency gems are installed otherwise.
if [ $1 == 0 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%package ovirt
Summary: Foreman ovirt support
Group:  Applications/System
Requires: rubygem(rbovirt) >= 0.0.15
Requires: foreman-ec2-%{version}-%{release}
Requires: %{name}-%{version}-%{release}

%description ovirt
Meta Package to install requirements for ovirt support

%files ovirt
%{_datadir}/%{name}/bundler.d/ovirt.rb

%post ovirt
if [ $1 == 1 ];then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%postun ovirt
if [ $1 == 0 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%package ec2
Summary: Foreman ec2 support
Group:  Applications/System
Requires: rubygem-fog >= 1.9.0
Requires: %{name}-%{version}-%{release}
Provides: foreman-ec2-%{version}-%{release}
Obsoletes: foreman-fog

%description ec2
Meta Package to install requirements for ec2 support

%files ec2
%{_datadir}/%{name}/bundler.d/fog.rb

%post ec2
if [ $1 == 1 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%postun ec2
if [ $1 == 0 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%package vmware
Summary: Foreman vmware support
Group:  Applications/System
Requires: rubygem(rbvmomi)
Requires: %{name}-%{version}-%{release}
Requires: foreman-ec2-%{version}-%{release}

%description vmware
Meta Package to install requirements for vmware support

%files vmware
%{_datadir}/%{name}/bundler.d/vmware.rb

%post vmware
if [ $1 == 1 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%postun vmware
if [ $1 == 0 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%package console
Summary: Foreman console support
Group:  Applications/System
Requires: rubygem(awesome_print)
Requires: rubygem(hirb-unicode)
Requires: rubygem(wirb)
Requires: %{name}-%{version}-%{release}

%description console
Meta Package to install requirements for console support

%files console
%{_datadir}/%{name}/bundler.d/console.rb

%post console
if [ $1 == 1 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%postun console
if [ $1 == 0 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%package mysql
Summary: Foreman mysql support
Group:  Applications/System
Requires: rubygem(mysql)
Requires: %{name}-%{version}-%{release}

%description mysql
Meta Package to install requirements for mysql support

%files mysql
%{_datadir}/%{name}/bundler.d/mysql.rb

%post mysql
if [ $1 == 1 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%postun mysql
if [ $1 == 0 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%package mysql2
Summary: Foreman mysql2 support
Group:  Applications/System
Requires: rubygem(mysql2)
Requires: %{name}-%{version}-%{release}

%description mysql2
Meta Package to install requirements for mysql2 support

%files mysql2
%{_datadir}/%{name}/bundler.d/mysql2.rb

%post mysql2
if [ $1 == 1 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%postun mysql2
if [ $1 == 0 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%package postgresql
Summary: Foreman Postgresql support
Group:  Applications/System
Requires: rubygem(pg)
Requires: %{name}-%{version}-%{release}

%description postgresql
Meta Package to install requirements for postgresql support

%files postgresql
%{_datadir}/%{name}/bundler.d/postgresql.rb

%post postgresql
if [ $1 == 1 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%postun postgresql
if [ $1 == 0 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%package sqlite
Summary: Foreman sqlite support
Group:  Applications/System
Requires: rubygem(sqlite3)
Requires: %{name}-%{version}-%{release}

%description sqlite
Meta Package to install requirements for sqlite support

%files sqlite
%{_datadir}/%{name}/bundler.d/sqlite.rb

%post sqlite
if [ $1 == 1 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%postun sqlite
if [ $1 == 0 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%package devel
Summary: Foreman devel support
Group:  Applications/System
Requires: rubygem(debug)
Requires: %{name}-%{version}-%{release}

%description devel
Meta Package to install requirements for devel support

%files devel
%{_datadir}/%{name}/bundler.d/development.rb

%post devel
if [ $1 == 1 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%postun devel
if [ $1 == 0 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%package test
Summary: Foreman test support
Group:  Applications/System
Requires: rubygem(mocha)
Requires: rubygem(shoulda)
Requires: rubygem(rr)
Requires: rubygem(rake)
Requires: %{name}-%{version}-%{release}

%description test
Meta Package to install requirements for test

%files test
%{_datadir}/%{name}/bundler.d/test.rb

%post test
if [ $1 == 1 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi

%postun test
if [ $1 == 0 ]; then
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
fi


%description
Foreman is aimed to be a Single Address For All Machines Life Cycle Management.
Foreman is based on Ruby on Rails, and this package bundles Rails and all
plugins required for Foreman to work.

%prep
%setup -q -n %{name}-%{version}
# Remove the references to git data in the Gemfile. This regex removes
# everything after the first comma, potentially including version
# information if it's specified.
sed -i 1d Gemfile
sed -i 's/,.*//' Gemfile
sed -i "1i\require File.expand_path('../config/settings', __FILE__)" Gemfile
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
install -Dp -m0644 %{confdir}/%{name}.logrotate %{buildroot}%{_sysconfdir}/logrotate.d/%{name}
install -Dp -m0644 %{confdir}/%{name}.cron.d %{buildroot}%{_sysconfdir}/cron.d/%{name}

install -dm 755 $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
install -pm 644 %{confdir}/%{name}.repo $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d

cp -p -r app bundler.d config config.ru extras Gemfile lib locale Rakefile script %{buildroot}%{_datadir}/%{name}
#chmod a+x %{buildroot}%{_datadir}/%{name}/script/{console,dbconsole,runner}
rm -rf %{buildroot}%{_datadir}/%{name}/extras/{jumpstart,spec}
# remove all test units from productive release
find %{buildroot}%{_datadir}/%{name} -type d -name "test" |xargs rm -rf

# Move config files to %{_sysconfdir}
mv %{buildroot}%{_datadir}/%{name}/config/database.yml.example %{buildroot}%{_datadir}/%{name}/config/database.yml
mv %{buildroot}%{_datadir}/%{name}/config/email.yaml.example %{buildroot}%{_datadir}/%{name}/config/email.yaml
mv %{buildroot}%{_datadir}/%{name}/config/settings.yaml.example %{buildroot}%{_datadir}/%{name}/config/settings.yaml
for i in database.yml email.yaml settings.yaml; do
mv %{buildroot}%{_datadir}/%{name}/config/$i %{buildroot}%{_sysconfdir}/%{name}
ln -sv %{_sysconfdir}/%{name}/$i %{buildroot}%{_datadir}/%{name}/config/$i
done
touch %{buildroot}%{_datadir}/%{name}/config/initializers/local_secret_token.rb

# Put db in %{_localstatedir}/lib/%{name}/db
cp -pr db/migrate db/seeds.rb %{buildroot}%{_datadir}/%{name}
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
echo %{version} > %{buildroot}%{_datadir}/%{name}/VERSION
%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,0755)
%exclude %{_datadir}/%{name}/bundler.d
%{_datadir}/%{name}
%{_initrddir}/%{name}
%config(noreplace) %{_sysconfdir}/%{name}
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
%config %{_sysconfdir}/cron.d/%{name}
%attr(-,%{name},%{name}) %{_localstatedir}/lib/%{name}
%attr(-,%{name},%{name}) %{_localstatedir}/log/%{name}
%attr(-,%{name},%{name}) %{_localstatedir}/run/%{name}
%attr(-,%{name},root) %{_datadir}/%{name}/config.ru
%attr(-,%{name},root) %{_datadir}/%{name}/config/environment.rb
%ghost %{_datadir}/%{name}/config/initializers/local_secret_token.rb
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
fi

varlibdir=%{_localstatedir}/run # /var/run
if [ ! -d $varlibdir/%{name} -a -d $datadir/tmp -a ! -L $datadir/tmp ]; then
  [ -d $varlibdir ] || mkdir -p $varlibdir
  mv $datadir/tmp $varlibdir/%{name} && ln -s $varlib/%{name} $datadir/tmp
fi

%post
if [ ! -f %{_datadir}/%{name}/config/initializers/local_secret_token.rb ]; then
  touch %{_datadir}/%{name}/config/initializers/local_secret_token.rb
  chmod 0640 %{_datadir}/%{name}/config/initializers/local_secret_token.rb
  chgrp foreman %{_datadir}/%{name}/config/initializers/local_secret_token.rb
  rake -f %{_datadir}/%{name}/Rakefile security:generate_token >/dev/null 2>&1 || :
fi
/sbin/chkconfig --add %{name} || :
(/sbin/service foreman status && /sbin/service foreman restart) >/dev/null 2>&1
exit 0

%posttrans
# We need to run the db:migrate after the  install transaction, because if there are updated gems and foreman-* packages we need to ensure everything is in place or bundler can get very upset about missing gems, etc.
cd /usr/share/foreman; rm -f Gemfile.lock; /usr/bin/bundle install --local 1>/dev/null 2>&1
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
* Fri Feb 15 2013 shk@redhat.com 1.1-3
- Bumped safemode dependency
* Thu Feb 14 2013 shk@redhat.com 1.1-2
- Fixed baseurl in the -release subpackage.
- Updated to 1.1-1
* Mon Feb 4 2013 shk@redhat.com 1.1-1
- 1.1 final.
* Mon Jan 28 2013 shk@redhat.com 1.1RC5-2
- Bumped fog version dependency
* Fri Jan 25 2013 shk@redhat.com 1.1RC5-1
- Updated Rails requirements and bumped to RC5.
* Thu Dec 27 2012 shk@redhat.com 1.1RC3-1
- Updated to 1.1RC3 and updated dependencies.
* Wed Dec 19 2012 jmontleo@redhat.com 1.0.2-1
- Fix Foreman SQL injection through search mechanism CVE-2012-5648
* Thu Aug 09 2012 jmontleo@redhat.com 1.0.1-1
- Version 1.0.1
* Sun Aug 05 2012 jmontleo@redhat.com 1.0.0-2
- Update to pull in fixes
* Mon Jul 23 2012 jmontleo@redhat.com 1.0.0-1
- Update packages for Foreman 1.0 Release and add support for using thin.
* Wed Jul 18 2012 jmontleo@redhat.com 1.0.0-0.7
- Updated pacakages for Foreman 1.0 RC5 and Proxy RC2
* Thu Jul 05 2012 jmontleo@redhat.com 1.0.0-0.6
- Fix foreman-release to account for different archs. Pull todays source.
* Wed Jul 04 2012 jmontleo@redhat.com 1.0.0-0.5
- Bump version number and rebuild for RC3
* Sun Jul 01 2012 jmontleo@redhat.com 1.0.0-0.4
- Pull todays develop branch to fix dbmigrate issue, add mistakenly deleted version string back, and replace foreman-fog with foreman-ec2 as it indicates more clearly what functionality the package provides.
* Fri Jun 29 2012 jmontleo@redhat.com 1.0.0-0.3
- More fixes for dbmigrate, foreman-cli and foreman-release added
* Fri Jun 29 2012 jmontleo@redhat.com 1.0.0-0.2
- Rebuild with develop branch from today for 1.0.0 RC2. Try to fix inconsistent db:migrate runs on upgrades.
* Tue Jun 19 2012 jmontleo@redhat.com 0-5.1-20
- Implement conf.d style Gemfile configuration for bundle to replace the ugly method used in previous rpm versions. Replace foreman-virt package with foreman-libvirt package as it was confusing to have fog virt ovirt and vmware.
* Tue Jun 19 2012 jmontleo@redhat.com 0-5.1-9
- Rebuild with todays develop branch. Add VERSION file 1688, add wget dependency 1514, update rbovirt dep to 0.0.12, and break out ovirt support to foreman-ovirt package.
* Thu Jun 14 2012 jmontleo@redhat.com 0.5.1-8
- Rebuild with todays develop branch.
* Wed Jun 13 2012 jmontleo@redhat.com 0.5.1-7
- Rebuild with todays develop branch. Add require for at least rubygem-rake 0.9.2.2. Run rake:db migrate on upgrade.
* Wed May 30 2012 jmontleo@redhat.com 0.5.1-5
- Rebuild with todays merge of compute resource RBAC patch
* Tue May 29 2012 jmontleo@redhat.com 0.5.1-4
- Fix rpm dependencies for foreman-virt and foreman-vmware to include foreman-fog
* Tue May 29 2012 jmontleo@redhat.com 0.5.1-3
- tidy up postinstall prepbundle.sh, rebuild with EC2 support, and split out foreman-fog and foreman-vmware support
* Tue May 08 2012 jmontleo@redhat.com 0.5.1-1
- adding prepbundle.sh to run post install of any foreman packages, other small fixes
* Fri May 04 2012 jmontleo@redhat.com 0.5.1-0.2
- updated foreman to develop branch from May 04 which included many fixes including no longer requiring foreman-virt
* Mon Jan 11 2012 ohadlevy@gmail.com - 0.4.2
- rebuilt
* Mon Dec 6 2011 ohadlevy@gmail.com - 0.4.1
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
