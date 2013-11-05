#
# spec file for package python-halite
#
# Copyright (c) 2012 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

Name:           python-halite
Version:        0.1.04
Release:        1%{?dist}
License:        MIT
Summary:        Halite the salt Web UI
Url:            http://saltstack.org/
Group:          System/Monitoring
Source0:        http://pypi.python.org/packages/source/h/halite/halite-%{version}.tar.gz
BuildRoot:      %{_tmppath}/halite-%{version}-build

%if 0%{?suse_version} && 0%{?suse_version} <= 1110
%{!?python_sitelib: %global python_sitelib %(python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}
%else
BuildArch:      noarch
%endif

BuildRequires:  fdupes
BuildRequires:  python
BuildRequires:  python-distribute
BuildRequires:	salt
BuildRequires:	salt-master
BuildRequires:  python-Paste
Requires:       salt
Requires:       salt-master
Requires:		python-Paste

%description
Halite is the salt web ui, from which you can run salt jobs/events and track progress

%prep
%setup -q -n halite-%{version}

%build
python setup.py build

%install
python setup.py install --prefix=%{_prefix} --root=%{buildroot}
%fdupes %{buildroot}%{_prefix}

%files
%defattr(-,root,root)
%doc README.rst
%attr(755,root,root)%{python_sitelib}/halite/bottle.py
%attr(755,root,root)%{python_sitelib}/halite/server_bottle.py
%attr(755,root,root)%{python_sitelib}/halite/genindex.py
%{python_sitelib}/*

%changelog
