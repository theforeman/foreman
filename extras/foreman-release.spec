
Name:           foreman-release
Version:        1
Release:        1
Summary:        Foreman repository files

Group:          System Environment/Base
License:        GPLv3+
URL:            http://theforeman.org/projects/foreman/
Source1:        foreman.repo
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:      noarch

%description
Foreman repository contains open source and other distributable software for
Fedora. This package contains the repository configuration for Yum.

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT

# yum
install -dm 755 $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
install -pm 644 %{SOURCE1} \
    $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%config(noreplace) %{_sysconfdir}/yum.repos.d/*

%changelog
* Sun May 22 2011 <fenris02@fedoraproject.org> - 1-1
- Initial release

