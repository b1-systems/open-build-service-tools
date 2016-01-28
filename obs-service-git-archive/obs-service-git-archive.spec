#
# spec file for package obs-service-git-archive
#
# Copyright (c) 2013 B1 Systems GmbH, Vohburg, Germany
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.




Name:           obs-service-git-archive
License:        GPL-2.0+
Group:          Development/Tools/Building
Summary:        An OBS source service: Fetch files/directories from git repository
Version:        0.1
Release:        1
Url:            https://www.b1-systems.de
Source:         git-archive
Source1:        git-archive.service
Requires:       tar
Requires:       bzip2
Requires:       xz
Requires:       gzip
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
This is a source service for openSUSE Build Service.

It fetches files or directories from a git repository.

%prep
%setup -q -D -T 0 -n .

%build

%install
mkdir -p $RPM_BUILD_ROOT/usr/lib/obs/service
install -m 0755 %{SOURCE0} $RPM_BUILD_ROOT/usr/lib/obs/service/git-archive
install -m 0644 %{SOURCE1} $RPM_BUILD_ROOT/usr/lib/obs/service/git-archive.service

%files
%defattr(-,root,root)
%dir /usr/lib/obs
/usr/lib/obs/service

%changelog
