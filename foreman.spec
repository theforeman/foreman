%global homedir %{_datadir}/%{name}
%global confdir extras/packaging/rpm/sources
%global foreman_rake %{_sbindir}/%{name}-rake

%if "%{?scl}" == "ruby193"
    %global scl_prefix %{scl}-
    %global scl_ruby /usr/bin/ruby193-ruby
    %global scl_rake /usr/bin/ruby193-rake
    ### TODO temp disabled for SCL
    %global nodoc 1
%else
    %global scl_ruby /usr/bin/ruby
    %global scl_rake /usr/bin/rake
%endif

Name:   foreman
Version: 1.6.0
Release: 0.develop%{?dist}
Summary:Systems Management web application

Group:  Applications/System
License: GPLv3+ with exceptions
URL: http://theforeman.org
Source0: %{name}-%{version}.tar.gz

BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:  noarch

%if 0%{?fedora} && 0%{?fedora} < 17
Requires: %{?scl_prefix}ruby(abi) = 1.8
%else
%if 0%{?fedora} && 0%{?fedora} > 18
Requires: %{?scl_prefix}ruby(release)
%else
Requires: %{?scl_prefix}ruby(abi) = 1.9.1
%endif
%endif
Requires: %{scl_ruby}
Requires: %{?scl_prefix}rubygems
Requires: %{?scl_prefix}facter
Requires: wget rsync
Requires: /etc/cron.d
Requires(pre):  shadow-utils
Requires(post): chkconfig
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(postun): initscripts
Requires: %{?scl_prefix}rubygem(json)
Requires: %{?scl_prefix}rubygem(rails) >= 3.2.8
Requires: %{?scl_prefix}rubygem(rails) < 3.3.0
Requires: %{?scl_prefix}rubygem(jquery-rails)
Requires: %{?scl_prefix}rubygem(rest-client)
Requires: %{?scl_prefix}rubygem(will_paginate) >= 3.0.0
Requires: %{?scl_prefix}rubygem(will_paginate) < 3.1.0
Requires: %{?scl_prefix}rubygem(ancestry) >= 2.0.0
Requires: %{?scl_prefix}rubygem(ancestry) < 3.0.0
Requires: %{?scl_prefix}rubygem(scoped_search) >= 2.5.0
Requires: %{?scl_prefix}rubygem(net-ldap)
Requires: %{?scl_prefix}rubygem(safemode) >= 1.2.0
Requires: %{?scl_prefix}rubygem(safemode) < 1.3.0
Requires: %{?scl_prefix}rubygem(uuidtools)
Requires: %{?scl_prefix}rubygem(oauth)
Requires: %{?scl_prefix}rubygem(rabl) >= 0.7.5
Requires: %{?scl_prefix}rubygem(rake) >= 0.8.3
Requires: %{?scl_prefix}rubygem(ruby_parser) >= 3.0.0
Requires: %{?scl_prefix}rubygem(audited-activerecord) >= 3.0.0
Requires: %{?scl_prefix}rubygem(apipie-rails) >= 0.1.1
Requires: %{?scl_prefix}rubygem(apipie-rails) < 0.2.0
Requires: %{?scl_prefix}rubygem(bundler_ext)
Requires: %{?scl_prefix}rubygem(thin)
Requires: %{?scl_prefix}rubygem(fast_gettext) >= 0.8.0
Requires: %{?scl_prefix}rubygem(gettext_i18n_rails) >= 0.10.0
Requires: %{?scl_prefix}rubygem(gettext_i18n_rails) < 1.0.0
Requires: %{?scl_prefix}rubygem(gettext_i18n_rails_js) >= 0.0.8
Requires: %{?scl_prefix}rubygem(i18n_data) >= 0.2.6
Requires: %{?scl_prefix}rubygem(therubyracer)
Requires: %{?scl_prefix}rubygem(jquery-ui-rails)
Requires: %{?scl_prefix}rubygem(bootstrap-sass) >= 3.0.3.0
Requires: %{?scl_prefix}rubygem(bootstrap-sass) < 3.0.4
Requires: %{?scl_prefix}rubygem(foreigner) >= 1.4.2
Requires: %{?scl_prefix}rubygem(deep_cloneable)
BuildRequires: %{?scl_prefix}rubygem(ancestry) >= 2.0.0
BuildRequires: %{?scl_prefix}rubygem(ancestry) < 3.0.0
BuildRequires: %{?scl_prefix}rubygem(apipie-rails) >= 0.1.1
BuildRequires: %{?scl_prefix}rubygem(apipie-rails) < 0.2.0
BuildRequires: %{?scl_prefix}rubygem(audited-activerecord) >= 3.0.0
BuildRequires: %{?scl_prefix}rubygem(bundler_ext)
BuildRequires: %{?scl_prefix}rubygem(gettext) >= 1.9.3
BuildRequires: %{?scl_prefix}rubygem(fast_gettext)
BuildRequires: %{?scl_prefix}rubygem(gettext_i18n_rails) >= 0.10.0
BuildRequires: %{?scl_prefix}rubygem(gettext_i18n_rails) < 1.0.0
BuildRequires: %{?scl_prefix}rubygem(gettext_i18n_rails_js) >= 0.0.8
BuildRequires: %{?scl_prefix}rubygem(i18n_data) >= 0.2.6
BuildRequires: %{?scl_prefix}rubygem(jquery-rails)
BuildRequires: %{?scl_prefix}rubygem(jquery-ui-rails)
BuildRequires: %{?scl_prefix}rubygem(less-rails)
BuildRequires: %{?scl_prefix}rubygem(net-ldap)
BuildRequires: %{?scl_prefix}rubygem(oauth)
BuildRequires: %{?scl_prefix}rubygem(rabl) >= 0.7.5
BuildRequires: %{?scl_prefix}rubygem(rake)
BuildRequires: %{?scl_prefix}rubygem(rest-client)
BuildRequires: %{?scl_prefix}rubygem(ruby_parser) >= 3.0.0
BuildRequires: %{?scl_prefix}rubygem(safemode) >= 1.2.0
BuildRequires: %{?scl_prefix}rubygem(sass-rails) => 3.2.3
BuildRequires: %{?scl_prefix}rubygem(scoped_search) >= 2.5.0
BuildRequires: %{?scl_prefix}rubygem(sqlite3)
BuildRequires: %{?scl_prefix}rubygem(therubyracer)
BuildRequires: %{?scl_prefix}rubygem(bootstrap-sass) >= 3.0.3.0
BuildRequires: %{?scl_prefix}rubygem(bootstrap-sass) < 3.0.4
BuildRequires: %{?scl_prefix}rubygem(uglifier) >= 1.0.3
BuildRequires: %{?scl_prefix}rubygem(uuidtools)
BuildRequires: %{?scl_prefix}rubygem(will_paginate) >= 3.0.2
BuildRequires: %{?scl_prefix}rubygem(rails)
BuildRequires: %{?scl_prefix}rubygem(quiet_assets)
BuildRequires: %{?scl_prefix}rubygem(spice-html5-rails)
BuildRequires: %{?scl_prefix}rubygem(flot-rails) = 0.0.3
BuildRequires: %{?scl_prefix}rubygem(foreigner) >= 1.4.2
BuildRequires: %{?scl_prefix}rubygem(multi-select-rails) >= 0.9.10
BuildRequires: %{?scl_prefix}rubygem(multi-select-rails) < 0.10.0
BuildRequires: %{?scl_prefix}rubygem(deep_cloneable)
BuildRequires: %{?scl_prefix}facter
BuildRequires: gettext
BuildRequires: asciidoc
BuildRequires: %{?scl_prefix}rubygem(rake)
BuildRequires: %{scl_ruby}

%package cli
Summary: Foreman CLI
Group: Applications/System
Requires: %{name} = %{version}-%{release}
Requires: rubygem(hammer_cli)
Requires: rubygem(hammer_cli_foreman)

%description cli
Meta Package to install hammer rubygems and its dependencies

%files cli

%package release
Summary:        Foreman repository files
Group:  	Applications/System


%description release
Foreman repository contains open source and other distributable software for
distributions in RPM format. This package contains the repository configuration
for Yum.

%files release
%config(noreplace) %{_sysconfdir}/yum.repos.d/*
/etc/pki/rpm-gpg/*

%package libvirt
Summary: Foreman libvirt support
Group:  Applications/System
Requires: %{?scl_prefix}rubygem(ruby-libvirt)
Requires: %{name} = %{version}-%{release}
Requires: foreman-compute = %{version}-%{release}
Obsoletes: foreman-virt < 1.0.0
Provides: foreman-virt = 1.0.0

%description libvirt
Meta Package to install requirements for virt support

%files libvirt
%{_datadir}/%{name}/bundler.d/libvirt.rb

%package ovirt
Summary: Foreman ovirt support
Group:  Applications/System
Requires: %{?scl_prefix}rubygem(rbovirt) >= 0.0.24
Requires: foreman-compute = %{version}-%{release}
Requires: %{name} = %{version}-%{release}

%description ovirt
Meta Package to install requirements for ovirt support

%files ovirt
%{_datadir}/%{name}/bundler.d/ovirt.rb

%package compute
Summary: Foreman Compute Resource support via fog
Group:  Applications/System
Requires: %{?scl_prefix}rubygem-fog >= 1.21.0
Requires: %{?scl_prefix}rubygem-fog < 1.22.0
Requires: %{?scl_prefix}rubygem-unf
Requires: %{name} = %{version}-%{release}
Obsoletes: foreman-fog < 1.0.0
Provides: foreman-fog = 1.0.0
Obsoletes: foreman-ec2
Provides: foreman-ec2

%description compute
Meta Package to install requirements for compute resource support, in
particular, Amazon EC2, OpenStack and Rackspace.

%files compute
%{_datadir}/%{name}/bundler.d/fog.rb

%package vmware
Summary: Foreman vmware support
Group:  Applications/System
Requires: %{?scl_prefix}rubygem(rbvmomi) >= 1.6.0
Requires: %{?scl_prefix}rubygem(rbvmomi) < 1.7.0
Requires: %{name} = %{version}-%{release}
Requires: foreman-compute = %{version}-%{release}

%description vmware
Meta Package to install requirements for vmware support

%files vmware
%{_datadir}/%{name}/bundler.d/vmware.rb

%package gce
Summary: Foreman Google Compute Engine (GCE) support
Group:  Applications/System
Requires: %{?scl_prefix}rubygem(google-api-client)
Requires: %{?scl_prefix}rubygem(sshkey)
Requires: %{name} = %{version}-%{release}
Requires: foreman-compute = %{version}-%{release}

%description gce
Meta package to install requirements for Google Compute Engine (GCE) support

%files gce
%{_datadir}/%{name}/bundler.d/gce.rb

%package assets
Summary: Foreman asset pipeline support
Group: Applications/system
Requires: %{name} = %{version}-%{release}
Requires: %{?scl_prefix}rubygem(jquery-rails) >= 2.0.2
Requires: %{?scl_prefix}rubygem(jquery-rails) < 2.1
Requires: %{?scl_prefix}rubygem(jquery-ui-rails)
Requires: %{?scl_prefix}rubygem(quiet_assets)
Requires: %{?scl_prefix}rubygem(sass-rails) >= 3.2.3
Requires: %{?scl_prefix}rubygem(sass-rails) < 3.3
Requires: %{?scl_prefix}rubygem(spice-html5-rails)
Requires: %{?scl_prefix}rubygem(therubyracer)
Requires: %{?scl_prefix}rubygem(bootstrap-sass) >= 3.0.3.0
Requires: %{?scl_prefix}rubygem(bootstrap-sass) < 3.0.4
Requires: %{?scl_prefix}rubygem(uglifier)
Requires: %{?scl_prefix}rubygem(flot-rails) = 0.0.3
Requires: %{?scl_prefix}rubygem(gettext_i18n_rails_js) >= 0.0.8
Requires: %{?scl_prefix}rubygem(gettext) >= 1.9.3
Requires: %{?scl_prefix}rubygem(multi-select-rails) >= 0.9.10
Requires: %{?scl_prefix}rubygem(multi-select-rails) < 0.10.0

%description assets
Meta package to install asset pipeline support.

%files assets
%{_datadir}/%{name}/bundler.d/assets.rb

%package console
Summary: Foreman console support
Group:  Applications/System
Requires: %{?scl_prefix}rubygem(awesome_print)
Requires: %{?scl_prefix}rubygem(hirb-unicode)
Requires: %{?scl_prefix}rubygem(wirb)
# minitest - workaround until Rails 4.0 (#2650)
Requires: %{?scl_prefix}rubygem(minitest)
Requires: %{name} = %{version}-%{release}

%description console
Meta Package to install requirements for console support

%files console
%{_datadir}/%{name}/bundler.d/console.rb

%package mysql2
Summary: Foreman mysql2 support
Group:  Applications/System
Requires: %{?scl_prefix}rubygem(mysql2)
Requires: %{name} = %{version}-%{release}
Obsoletes: %{name}-mysql < 1.4.0
Provides: %{name}-mysql = %{version}

%description mysql2
Meta Package to install requirements for mysql2 support

%files mysql2
%{_datadir}/%{name}/bundler.d/mysql2.rb

%package postgresql
Summary: Foreman Postgresql support
Group:  Applications/System
Requires: %{?scl_prefix}rubygem(pg)
Requires: %{name} = %{version}-%{release}

%description postgresql
Meta Package to install requirements for postgresql support

%files postgresql
%{_datadir}/%{name}/bundler.d/postgresql.rb

%package sqlite
Summary: Foreman sqlite support
Group:  Applications/System
Requires: %{?scl_prefix}rubygem(sqlite3)
Requires: %{name} = %{version}-%{release}

%description sqlite
Meta Package to install requirements for sqlite support

%files sqlite
%{_datadir}/%{name}/bundler.d/sqlite.rb

# <devel packages are not SCL enabled yet - not avaiable on SCL platforms>
%if %{?scl:0}%{!?scl:1}

%package devel
Summary: Foreman devel support
Group:  Applications/System
Requires: %{?scl_prefix}rubygem(ruby-debug19)
Requires: %{name} = %{version}-%{release}
Requires: %{name}-cli = %{version}-%{release}
Requires: %{name}-libvirt = %{version}-%{release}
Requires: %{name}-ovirt = %{version}-%{release}
Requires: %{name}-compute = %{version}-%{release}
Requires: %{name}-vmware = %{version}-%{release}
Requires: %{name}-gce = %{version}-%{release}
Requires: %{name}-console = %{version}-%{release}
Requires: %{name}-mysql2 = %{version}-%{release}
Requires: %{name}-postgresql = %{version}-%{release}
Requires: %{name}-sqlite = %{version}-%{release}
Requires: %{name}-test = %{version}-%{release}
Requires: %{?scl_prefix}rubygem(ci_reporter)
Requires: %{?scl_prefix}rubygem(gettext)
Requires: %{?scl_prefix}rubygem(maruku)
Requires: %{?scl_prefix}rubygem(single_test)
Requires: %{?scl_prefix}rubygem(pry)
Requires: %{?scl_prefix}rubygem(term-ansicolor)
Requires: %{?scl_prefix}rubygem(rack-mini-profiler)
Requires: %{?scl_prefix}rubygem(immigrant)
Requires: %{name}-assets = %{version}-%{release}

%description devel
Meta Package to install requirements for devel support

%files devel
%{_datadir}/%{name}/bundler.d/development.rb

%package test
Summary: Foreman test support
Group:  Applications/System
Requires: %{?scl_prefix}rubygem(mocha)
Requires: %{?scl_prefix}rubygem(rake)
Requires: %{?scl_prefix}rubygem(maruku)
Requires: %{?scl_prefix}rubygem(single_test)
Requires: %{name} = %{version}-%{release}

%description test
Meta Package to install requirements for test

%files test
%{_datadir}/%{name}/bundler.d/test.rb

%endif

%description
Foreman is aimed to be a Single Address For All Machines Life Cycle Management.
Foreman is based on Ruby on Rails, and this package bundles Rails and all
plugins required for Foreman to work.

%prep
%setup -q

%build
#build man pages
%{scl_rake} -f Rakefile.dist build \
  PREFIX=%{_prefix} \
  SBINDIR=%{_sbindir} \
  SYSCONFDIR=%{_sysconfdir} \
  --trace

#replace shebangs and binaries in scripts for SCL
%if %{?scl:1}%{!?scl:0}
  # shebangs
  for f in extras/query/ssh_using_foreman extras/rdoc/rdoc_prepare_script.rb \
  script/rails script/performance/profiler script/performance/benchmarker script/foreman-config ; do
    sed -ri '1sX(/usr/bin/ruby|/usr/bin/env ruby)X%{scl_ruby}X' $f
  done
  sed -ri '1,$sX/usr/bin/rubyX%{scl_ruby}X' %{confdir}/foreman.init
  sed -ri '1,$s|THIN=/usr/bin/thin|THIN="run_in_scl"|' %{confdir}/foreman.init
  # script content
  sed -ri 'sX/usr/bin/rakeX%{scl_rake}X' extras/dbmigrate script/foreman-rake
%endif

#build locale files
make -C locale all-mo

#use Bundler_ext instead of Bundler
mv Gemfile Gemfile.in

# fix the issue with loading scoped_search
# upstream bug https://github.com/wvanbergen/scoped_search/issues/53
sed -i "s/gem 'scoped_search'/gem 'sprockets'\n&/" Gemfile.in
cp config/database.yml.example config/database.yml
cp config/settings.yaml.example config/settings.yaml
export BUNDLER_EXT_NOSTRICT=1
export BUNDLER_EXT_GROUPS="default assets"
%{scl_rake} assets:precompile:all RAILS_ENV=production --trace
rm config/database.yml config/settings.yaml

%install
rm -rf %{buildroot}

#install man pages
%{scl_rake} -f Rakefile.dist install \
  PREFIX=%{buildroot}%{_prefix} \
  SBINDIR=%{buildroot}%{_sbindir} \
  SYSCONFDIR=%{buildroot}%{_sysconfdir} \
  --trace
%{scl_rake} -f Rakefile.dist clean

install -d -m0755 %{buildroot}%{_datadir}/%{name}
install -d -m0755 %{buildroot}%{_datadir}/%{name}/plugins
install -d -m0755 %{buildroot}%{_sysconfdir}/%{name}
install -d -m0755 %{buildroot}%{_sysconfdir}/%{name}/plugins
install -d -m0755 %{buildroot}%{_localstatedir}/lib/%{name}
install -d -m0755 %{buildroot}%{_localstatedir}/lib/%{name}/tmp
install -d -m0755 %{buildroot}%{_localstatedir}/lib/%{name}/tmp/pids
install -d -m0755 %{buildroot}%{_localstatedir}/run/%{name}
install -d -m0750 %{buildroot}%{_localstatedir}/log/%{name}
install -d -m0750 %{buildroot}%{_localstatedir}/log/%{name}/plugins
install -Dp -m0755 script/%{name}-debug %{buildroot}%{_sbindir}/%{name}-debug
install -Dp -m0755 script/%{name}-rake %{buildroot}%{_sbindir}/%{name}-rake
install -Dp -m0755 script/%{name}-tail %{buildroot}%{_sbindir}/%{name}-tail
install -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0755 %{confdir}/%{name}.init %{buildroot}%{_initrddir}/%{name}
install -Dp -m0644 %{confdir}/%{name}.logrotate %{buildroot}%{_sysconfdir}/logrotate.d/%{name}
install -Dp -m0644 %{confdir}/%{name}.cron.d %{buildroot}%{_sysconfdir}/cron.d/%{name}
%if 0%{?rhel} > 6 || 0%{?fedora} > 16
install -Dp -m0644 %{confdir}/%{name}.tmpfiles %{buildroot}%{_prefix}/lib/tmpfiles.d/%{name}.conf
%endif

install -Dpm0644 %{confdir}/%{name}.repo %{buildroot}%{_sysconfdir}/yum.repos.d/%{name}.repo
install -Dpm0644 %{confdir}/%{name}-plugins.repo %{buildroot}%{_sysconfdir}/yum.repos.d/%{name}-plugins.repo
sed "s/\$DIST/$(echo %{?dist} | sed 's/^\.//')/g" -i %{buildroot}%{_sysconfdir}/yum.repos.d/%{name}*.repo
install -Dpm0644 %{confdir}/%{name}.gpg %{buildroot}%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-foreman

cp -p Gemfile.in %{buildroot}%{_datadir}/%{name}/Gemfile.in
cp -p -r app bundler.d config config.ru extras lib locale Rakefile script %{buildroot}%{_datadir}/%{name}
rm -rf %{buildroot}%{_datadir}/%{name}/extras/{jumpstart,spec}

# remove all test units from produciton release
find %{buildroot}%{_datadir}/%{name} -type d -name "test" |xargs rm -rf

# Move config files to %{_sysconfdir}
mv %{buildroot}%{_datadir}/%{name}/config/database.yml.example %{buildroot}%{_datadir}/%{name}/config/database.yml
mv %{buildroot}%{_datadir}/%{name}/config/email.yaml.example %{buildroot}%{_datadir}/%{name}/config/email.yaml
mv %{buildroot}%{_datadir}/%{name}/config/settings.yaml.example %{buildroot}%{_datadir}/%{name}/config/settings.yaml

for i in database.yml email.yaml settings.yaml; do
mv %{buildroot}%{_datadir}/%{name}/config/$i %{buildroot}%{_sysconfdir}/%{name}
ln -sv %{_sysconfdir}/%{name}/$i %{buildroot}%{_datadir}/%{name}/config/$i
done

# Put db in %{_localstatedir}/lib/%{name}/db
cp -pr db/migrate db/seeds.rb db/seeds.d %{buildroot}%{_datadir}/%{name}
mkdir %{buildroot}%{_localstatedir}/lib/%{name}/db

ln -sv %{_localstatedir}/lib/%{name}/db %{buildroot}%{_datadir}/%{name}/db
ln -sv %{_datadir}/%{name}/migrate %{buildroot}%{_localstatedir}/lib/%{name}/db/migrate
ln -sv %{_datadir}/%{name}/seeds.rb %{buildroot}%{_localstatedir}/lib/%{name}/db/seeds.rb
ln -sv %{_datadir}/%{name}/seeds.d %{buildroot}%{_localstatedir}/lib/%{name}/db/seeds.d

# Put HTML %{_localstatedir}/lib/%{name}/public
cp -pr public %{buildroot}%{_localstatedir}/lib/%{name}/
ln -sv %{_localstatedir}/lib/%{name}/public %{buildroot}%{_datadir}/%{name}/public

# Put logs in %{_localstatedir}/log/%{name}
ln -sv %{_localstatedir}/log/%{name} %{buildroot}%{_datadir}/%{name}/log

# Put tmp files in %{_localstatedir}/run/%{name}
ln -sv %{_localstatedir}/run/%{name} %{buildroot}%{_datadir}/%{name}/tmp

# Symlink plugin settings directory to
ln -sv %{_sysconfdir}/%{name}/plugins %{buildroot}%{_datadir}/%{name}/config/settings.plugins.d

# Create VERSION file
install -pm0644 VERSION %{buildroot}%{_datadir}/%{name}/VERSION

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,0755)
%doc README.md
%doc VERSION
%doc LICENSE
%exclude %{_datadir}/%{name}/bundler.d/*
%{_datadir}/%{name}
%{_datadir}/%{name}/plugins
%exclude %{_datadir}/%{name}/app/assets
%{_initrddir}/%{name}
%{_sbindir}/%{name}-debug
%{_sbindir}/%{name}-rake
%{_sbindir}/%{name}-tail
%{_mandir}/man8
%config(noreplace) %{_sysconfdir}/%{name}
%ghost %attr(0640,root,%{name}) %config(noreplace) %{_sysconfdir}/%{name}/encryption_key.rb
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
%config %{_sysconfdir}/cron.d/%{name}
%attr(-,%{name},%{name}) %{_localstatedir}/lib/%{name}
%attr(750,%{name},%{name}) %{_localstatedir}/log/%{name}
%attr(750,%{name},%{name}) %{_localstatedir}/log/%{name}/plugins
%attr(-,%{name},%{name}) %{_localstatedir}/run/%{name}
%attr(-,%{name},root) %{_datadir}/%{name}/config.ru
%attr(-,%{name},root) %{_datadir}/%{name}/config/environment.rb
# Symlink to /etc, EL6 needs attrs for ghost files, Fedora doesn't
%if 0%{?rhel} == 6
%ghost %attr(0777,root,root) %{_datadir}/%{name}/config/initializers/encryption_key.rb
%else
%ghost %{_datadir}/%{name}/config/initializers/encryption_key.rb
%endif
%ghost %attr(0640,root,%{name}) %config(noreplace) %{_datadir}/%{name}/config/initializers/local_secret_token.rb
# Only need tmpfiles on systemd (F17 and up)
%if 0%{?rhel} > 6 || 0%{?fedora} > 16
%{_prefix}/lib/tmpfiles.d/%{name}.conf
%endif

%pre
# Add the "foreman" user and group
getent group %{name} >/dev/null || groupadd -r %{name}
getent passwd %{name} >/dev/null || \
useradd -r -g %{name} -d %{homedir} -s /sbin/nologin -c "Foreman" %{name}
exit 0

%post
# secret token used for cookie signing etc.
if [ ! -f %{_datadir}/%{name}/config/initializers/local_secret_token.rb ]; then
  touch %{_datadir}/%{name}/config/initializers/local_secret_token.rb
  chmod 0660 %{_datadir}/%{name}/config/initializers/local_secret_token.rb
  chgrp foreman %{_datadir}/%{name}/config/initializers/local_secret_token.rb
  %{foreman_rake} security:generate_token >/dev/null 2>&1 || :
  chmod 0640 %{_datadir}/%{name}/config/initializers/local_secret_token.rb
fi

# encryption key used to encrypt DB contents
# move the generated key file to /etc/foreman/ so users back it up, symlink to it from ~foreman
if [ ! -e %{_datadir}/%{name}/config/initializers/encryption_key.rb -a \
     ! -e %{_sysconfdir}/%{name}/encryption_key.rb ]; then
  touch %{_datadir}/%{name}/config/initializers/encryption_key.rb
  chmod 0660 %{_datadir}/%{name}/config/initializers/encryption_key.rb
  chgrp foreman %{_datadir}/%{name}/config/initializers/encryption_key.rb
  %{foreman_rake} security:generate_encryption_key >/dev/null 2>&1 || :
  chmod 0640 %{_datadir}/%{name}/config/initializers/encryption_key.rb
  mv %{_datadir}/%{name}/config/initializers/encryption_key.rb %{_sysconfdir}/%{name}/
fi
if [ ! -e %{_datadir}/%{name}/config/initializers/encryption_key.rb -a \
     -e %{_sysconfdir}/%{name}/encryption_key.rb ]; then
  ln -s %{_sysconfdir}/%{name}/encryption_key.rb %{_datadir}/%{name}/config/initializers/
fi

/sbin/chkconfig --add %{name} || :
(/sbin/service foreman status && /sbin/service foreman restart) >/dev/null 2>&1
exit 0

%posttrans
# We need to run the db:migrate after the install transaction
# always attempt to reencrypt after update in case new fields can be encrypted
%{foreman_rake} db:migrate db:compute_resources:encrypt >> %{_localstatedir}/log/%{name}/db_migrate.log 2>&1 || :
%{foreman_rake} db:seed >> %{_localstatedir}/log/%{name}/db_seed.log 2>&1 || :
%{foreman_rake} apipie:cache >> %{_localstatedir}/log/%{name}/apipie_cache.log 2>&1 || :
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
* Wed Apr 16 2014 Dominic Cleal <dcleal@redhat.com> - 1.6.0-0.develop
- Bump version to 1.6-develop

* Thu Jan 16 2014 Dominic Cleal <dcleal@redhat.com> - 1.5.0-0.develop
- Bump version to 1.5-develop
- Remove rails3_before_render dependency
- generate encryption key and encrypt data in postinstall (#2929)

* Thu Nov 21 2013 Dominic Cleal <dcleal@redhat.com> - 1.4.0-0.develop
- Bump and change versioning scheme, don't overwrite VERSION (#3712)
- Pin fog to 1.18.x
- Add new rails3_before_render dependency
- Removed foreman-mysql package (obsoleted by mysql2)
- Seed database after DB migration
- Change twitter-bootstrap-rails to bootstrap-sass
- Pin fog to 1.19.x
- Add BR and explicit dependency on Ruby binary, for ruby193-ruby-wrapper

* Tue Nov 12 2013 Sam Kottler <shk@redhat.com> - 1.3.9999-7
- Add rubygem-unf as a requires for the compute subpackage

* Sun Nov 10 2013 Dominic Cleal <dcleal@redhat.com> - 1.3.9999-6
* Add foreman-gce subpackage for Google Compute Engine

* Wed Nov 6 2013 David Davis <daviddavis@redhat.com> - 1.3.9999-5
- Removing rr gem, fixes #3597

* Fri Oct 25 2013 Martin Bacovsky <mbacovsk@redhat.com> - 1.3.9999-4
- foreman-cli metapackage installs hammer

* Mon Sep 30 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.3.9999-3
- Adding Foreman plugins repo

* Fri Sep 27 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.3.9999-2
- Update rubygem-ancestry to 2.x

* Wed Sep 11 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.3.9999-1
- Bump to version 1.3-develop

* Wed Sep 11 2013 Dominic Cleal <dcleal@redhat.com> - 1.2.9999-11
- Add new foreigner and immigrant dependencies

* Mon Sep 09 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.2.9999-10
- Added dependency on fast_gettext 0.8 (multi-domain support)

* Mon Sep 02 2013 Greg Sutcliffe <gsutclif@redhat.com> 1.2.9999-9
- Remove Puppet from core requirements

* Fri Aug 16 2013 Sam Kottler <shk@redhat.com> 1.2.9999-8
- Update fog dependency to 1.15.0 to fix rackspace VM listing issue

* Wed Jul 24 2013 Jason Montleon <jmontleo@redhat.com> 1.2.9999-7
- Update rbovirt dependency version to 0.0.21 to support sending the host ssl certificate subject as an option to the xpi plugin

* Fri Jul 19 2013 Dominic Cleal <dcleal@redhat.com> 1.2.9999-6
- add foreman-rake to /usr/sbin

* Mon Jun 17 2013 Dominic Cleal <dcleal@redhat.com> 1.2.9999-5
- fix asset dependency versions
- add minitest dependency for console (Lukas Zapletal)

* Thu Jun 06 2013 Dominic Cleal <dcleal@redhat.com> 1.2.9999-4
- fix libvirt package dependency on ruby-libvirt

* Wed Jun 05 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.2.9999-3
- foreman-debug tool now installed into /usr/sbin

* Tue May 28 2013 Dominic Cleal <dcleal@redhat.com> 1.2.9999-2
- Don't force SCL
- Distribute GPG key
- Replace dist in foreman.repo
- Rename foreman-ec2 to foreman-compute
- Update dbmigrate for SCL (Lukas Zapletal)

* Mon May 20 2013 Dominic Cleal <dcleal@redhat.com> 1.2.9999-1
- Updated to 1.2.9999 (1.3-pre)

* Tue Apr 30 2013 Sam Kottler <shk@redhat.com> 1.1.9999-1
- Updated to 1.1.9999 (1.2-pre)

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

* Wed Jan 11 2012 ohadlevy@gmail.com - 0.4.2
- rebuilt

* Tue Dec 6 2011 ohadlevy@gmail.com - 0.4.1
- rebuilt

* Tue Nov 08 2011 ohadlevy@gmail.com - 0.4
- rebuilt

* Mon Nov 07 2011 ohadlevy@gmail.com - 0.4rc5
- rebuilt

* Tue Oct 25 2011 ohadlevy@gmail.com - 0.4rc4
- rebuilt

* Tue Oct 18 2011 ohadlevy@gmail.com - 0.4rc3
- rebuilt

* Wed Sep 28 2011 ohadlevy@gmail.com - 0.4rc2
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

* Fri Nov 12 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.6-1
- Included fix for #461, as without it newly installed instances are not usable

* Thu Nov 11 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.6
- New upstream version

* Sat Oct 30 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.6rc2
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

* Mon Apr 19 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1-4-3
- added status to startup script
- removed puppet module from the RPM

* Mon Apr 12 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.4-2
- Added startup script for built in webrick server
- Changed foreman user default shell to /sbin/nologin and is now part of the puppet group
- defaults to sqlite database

* Tue Apr 6 2010 Ohad Levy <ohadlevy@gmail.com> - 0.1.4-1
- Initial release.
