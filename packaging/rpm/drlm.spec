%define rpmrelease git

### Work-around the fact that OpenSUSE/SLES _always_ defined both :-/
%if 0%{?sles_version} == 0
%undefine sles_version
%endif

Summary: DRLM
Name: drlm
Version: 1.00
Release: %{?rpmrelease}%{?dist}
License: GPLv3
Group: Applications/File
#URL: 

Source: http://drlm.org/download/

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildArch: noarch

### Dependencies on all distributions
Requires: openssh-clients openssl nc
Requires: wget gzip tar
Requires: gawk sed grep
Requires: coreutils util-linux
Requires: nfs-utils portmap rpcbind 
Requires: dhcp tftp-server httpd

### Optional requirement
#Requires: cfg2html

%ifarch %ix86 x86_64
Requires: syslinux
%endif
#%ifarch ppc ppc64
#Requires: yaboot
#%endif

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

### On RHEL/Fedora the genisoimage packages provides mkisofs
%if %{?centos_version:1}%{?fedora_version:1}%{?rhel_version:1}0
Requires: crontabs
%endif

#Obsoletes: 

%description
DRLM is an Open Source disaster recovery and system ...
...
...

Professional services and support are available.

%prep
#%setup -q -n drlm-1.00-git
%setup -q 

#echo "55 0 * * * root /usr/sbin/drlm sched" >drlm.cron

### Add a specific os.conf so we do not depend on LSB dependencies
%{?fedora:echo -e "OS_VENDOR=Fedora\nOS_VERSION=%{?fedora}" >etc/drlm/os.conf}
%{?mdkversion:echo -e "OS_VENDOR=Mandriva\nOS_VERSION=%{distro_rel}" >etc/drlm/os.conf}
%{?rhel:echo -e "OS_VENDOR=RedHatEnterpriseServer\nOS_VERSION=%{?rhel}" >etc/drlm/os.conf}
%{?sles_version:echo -e "OS_VENDOR=SUSE_LINUX\nOS_VERSION=%{?sles_version}" >etc/drlm/os.conf}
### Doesn't work as, suse_version for OpenSUSE 11.3 is 1130
%{?suse_version:echo -e "OS_VENDOR=SUSE_LINUX\nOS_VERSION=%{?suse_version}" >etc/drlm/os.conf}

%build

%install
%{__rm} -rf %{buildroot}
%{__make} install DESTDIR="%{buildroot}"
#%{__install} -Dp -m0644 drlm.cron %{buildroot}%{_sysconfdir}/cron.d/drlm
%{__install} -Dp -m0755 etc/init.d/drlm-stord %{buildroot}%{_sysconfdir}/init.d/drlm-stord

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
#%doc AUTHORS COPYING README doc/*.txt
%doc AUTHORS COPYING README 
%doc %{_mandir}/man8/drlm.8*
#%config(noreplace) %{_sysconfdir}/cron.d/drlm
%config(noreplace) %{_sysconfdir}/drlm/
%{_datadir}/drlm/
%config(noreplace) %{_localstatedir}/lib/drlm/
%{_sbindir}/drlm
%{_sysconfdir}/init.d/drlm-stord

#%changelog
#* Sun Apr 08 2013 Didac Oliveira
#- Initial package. 
