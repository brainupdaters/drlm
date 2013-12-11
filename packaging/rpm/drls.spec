%define rpmrelease .git201312082027

### Work-around the fact that OpenSUSE/SLES _always_ defined both :-/
%if 0%{?sles_version} == 0
%undefine sles_version
%endif

Summary: Relax-and-Recover is a Linux disaster recovery and system migration tool
Name: drls
Version: 1.00-git201312082025
Release: 1%{?rpmrelease}%{?dist}
License: GPLv3
Group: Applications/File
#URL: 

Source: https://future_drls_website/drls/1.00-git201312082025/drls-1.00-git201312082025-git201312082027.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildArch: noarch

### Dependencies on all distributions
#Requires: binutils
#Requires: ethtool
#Requires: gzip
#Requires: iputils
#Requires: mingetty
#Requires: parted
#Requires: tar
#Requires: util-linux
#Requires: openssl

### If you require NFS, you may need the below packages
#Requires: nfsclient portmap rpcbind

### We drop LSB requirements because it pulls in too many dependencies
### The OS is hardcoded in /etc/drls/os.conf instead
#Requires: redhat-lsb

### Required for Bacula/MySQL support
#Requires: bacula-mysql

### Required for OBDR
#Requires: lsscsi sg3_utils

### Optional requirement
#Requires: cfg2html

%ifarch %ix86 x86_64
#Requires: syslinux
%endif
%ifarch ppc ppc64
#Requires: yaboot
%endif

%if %{?suse_version:1}0
#Requires: iproute2
### recent SuSE versions have an extra nfs-client package
### and switched to genisoimage/wodim
%if 0%{?suse_version} >= 1020
#Requires: genisoimage
%else
#Requires: mkisofs
%endif
###
%if %{!?sles_version:1}0
#Requires: lsb
%endif
%endif

%if %{?mandriva_version:1}0
#Requires: iproute2
### Mandriva switched from 2008 away from mkisofs,
### and as a specialty call the package cdrkit-genisoimage!
%if 0%{?mandriva_version} >= 2008
#Requires: cdrkit-genisoimage
%else
#Requires: mkisofs
%endif
#Requires: lsb
%endif

### On RHEL/Fedora the genisoimage packages provides mkisofs
%if %{?centos_version:1}%{?fedora_version:1}%{?rhel_version:1}0
Requires: crontabs
#Requires: iproute
#Requires: mkisofs
#Requires: redhat-lsb
%endif

#Obsoletes: 

%description
DRLS is an Open Source disaster recovery and system ...
...
...

Professional services and support are available.

%prep
%setup -q -n drls-1.00-git201312082025-git201312082027

#echo "55 0 * * * root /usr/sbin/drls sched" >drls.cron

### Add a specific os.conf so we do not depend on LSB dependencies
%{?fedora:echo -e "OS_VENDOR=Fedora\nOS_VERSION=%{?fedora}" >etc/drls/os.conf}
%{?mdkversion:echo -e "OS_VENDOR=Mandriva\nOS_VERSION=%{distro_rel}" >etc/drls/os.conf}
%{?rhel:echo -e "OS_VENDOR=RedHatEnterpriseServer\nOS_VERSION=%{?rhel}" >etc/drls/os.conf}
%{?sles_version:echo -e "OS_VENDOR=SUSE_LINUX\nOS_VERSION=%{?sles_version}" >etc/drls/os.conf}
### Doesn't work as, suse_version for OpenSUSE 11.3 is 1130
#%{?suse_version:echo -e "OS_VENDOR=SUSE_LINUX\nOS_VERSION=%{?suse_version}" >etc/drls/os.conf}

%build

%install
%{__rm} -rf %{buildroot}
%{__make} install DESTDIR="%{buildroot}"
#%{__install} -Dp -m0644 drls.cron %{buildroot}%{_sysconfdir}/cron.d/drls

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
#%doc AUTHORS COPYING README doc/*.txt
%doc AUTHORS COPYING README 
#%doc %{_mandir}/man8/drls.8*
#%config(noreplace) %{_sysconfdir}/cron.d/drls
%config(noreplace) %{_sysconfdir}/drls/
%{_datadir}/drls/
%{_localstatedir}/lib/drls/
%{_sbindir}/drls

%changelog
* Sun Dec 08 2013 Didac Oliveira
- Initial package. 
