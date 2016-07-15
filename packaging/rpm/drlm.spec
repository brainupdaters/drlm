%define rpmrelease %{nil}

# Because a problem with Arch dependent GRUB2 modules
%define _binaries_in_noarch_packages_terminate_build   0

### Work-around the fact that OpenSUSE/SLES _always_ defined both :-/
%if 0%{?sles_version} == 0
%undefine sles_version
%endif

Summary: DRLM
Name: drlm
Version: 2.0.0
Release: 1%{?rpmrelease}%{?dist}
License: GPLv3
Group: Applications/File
URL: http://drlm.org/

Source: http://drlm.org/download/

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildArch: noarch

### Dependencies on all distributions
Requires: openssh-clients openssl
Requires: wget gzip tar
Requires: gawk sed grep
Requires: coreutils util-linux
Requires: nfs-utils portmap rpcbind
Requires: dhcp tftp-server httpd
Requires: qemu-img

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
DRLM is an Open Source disaster recovery solution...
...
...

Professional services and support are available.

%prep
%setup -q

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

%post
%if %(ps -p 1 -o comm=) == "systemd"
systemctl enable xinetd.service
systemctl enable rpcbind.service
systemctl enable nfs.service
systemctl enable dhcpd.service
systemctl enable httpd.service
%{__cp} /usr/share/drlm/conf/systemd/drlm-stord.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable drlm-stord.service
systemctl start drlm-stord.service
%else
chkconfig xinetd on
chkconfig rpcbind on
chkconfig nfs on
chkconfig dhcpd on
chkconfig httpd on
%{__cp} /usr/sbin/drlm-stord /etc/init.d/
chkconfig drlm-stord on
service drlm-stord start
%endif

%preun
%if %(ps -p 1 -o comm=) == "systemd"
systemctl stop drlm-stord.service
systemctl disable drlm-stord.service
systemctl daemon-reload
%{__rm} /usr/share/drlm/conf/systemd/drlm-stord.service /etc/systemd/system/
%else
service drlm-stord stop
chkconfig drlm-stord off
%endif

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%doc AUTHORS COPYING README.rst
%doc %{_mandir}/man8/drlm.8*
%config(noreplace) %{_sysconfdir}/drlm/
%{_datadir}/drlm/
%config(noreplace) %{_localstatedir}/lib/drlm/
%{_sbindir}/drlm
%{_sbindir}/drlm-stord

%changelog
* Sat Jul 16 2016 Didac Oliveira <didac@brainupdaters.net> 2.0.0
- Multiarch netboot with GRUB2.
- New installclient workflow.
- Systemd support.
- Netcat replacement with bash socket implementation.
- Improvement of runbackup workflow.
- Parallel backups support.
- New database backend (sqlite3).
- New error reporting methods (mail,nagios,zabbix).
- lots of bug fixes.

* Thu Feb 11 2016 Pau Roura <pau@brainupdaters.net> 1.1.3
- bugfixes.

* Wed Feb 10 2016 Pau Roura <pau@brainupdaters.net> 1.1.2
- bugfixes.

* Mon Mar 30 2015 Pau Roura <pau@brainupdaters.net> 1.1.1
- bugfixes.

* Wed Mar 18 2015 Pau Roura <pau@brainupdaters.net> 1.1.0
- new features.
- bugfixes.

* Mon Apr 08 2013 Didac Oliveira <didac@brainupdaters.net> 1.0.0
- Initial package.
