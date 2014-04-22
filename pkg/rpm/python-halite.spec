%if ! (0%{?rhel} >= 6 || 0%{?fedora} > 12)
%global pybasever 2.6
%global __python_ver 26
%global __python %{_bindir}/python%{?pybasever}
%endif

%global _realname halite

Name:           python-halite
Version:        0.1.16
Release:        1%{?dist}
Summary:        SaltStack Web UI

Group:          Development/Languages
License:        ASL 2.0
URL:            https://github.com/saltstack/halite/
Source0:        https://pypi.python.org/packages/source/h/%{_realname}/%{_realname}-%{version}.tar.gz
Source1:        https://raw.github.com/saltstack/%{_realname}/v%{version}/LICENSE
BuildArch:      noarch

BuildRequires:  python-setuptools

Requires:       python-cherrypy

%description
Halite is a Salt GUI. Status is pre-alpha. Contributions are very welcome. Join
us in #salt-devel on Freenode or on the salt-users mailing list.

%prep
%setup -q -n %{_realname}-%{version}

%build

%install
install -p -m 0644 %{SOURCE1} $RPM_BUILD_DIR/LICENSE
%{__python} setup.py install -O1 --root $RPM_BUILD_ROOT

# Remove shebang
sed -i '1{\@^#!/usr/bin/env python@d}' ${RPM_BUILD_ROOT}%{python_sitelib}/%{_realname}/bottle.py

# Add execute bit for scripts which need to be executed
chmod 0755 ${RPM_BUILD_ROOT}%{python_sitelib}/%{_realname}/server_bottle.py
chmod 0755 ${RPM_BUILD_ROOT}%{python_sitelib}/%{_realname}/genindex.py

%files
%doc $RPM_BUILD_DIR/LICENSE
%{python_sitelib}/*

%changelog
* Tue Apr 22 2014 Erik Johnson <erik@saltstack.com> - 0.1.16-1
- Updated to version 0.1.16.

* Thu Dec 19 2013 Erik Johnson <erik@saltstack.com> - 0.1.13-1
- Updated to version 0.1.13.

* Mon Oct 21 2013 Erik Johnson <erik@saltstack.com> - 0.1.02-1
- Initial build.
