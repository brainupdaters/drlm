%define rpmrelease %{nil}

# Because a problem with Arch dependent GRUB2 modules
%define _binaries_in_noarch_packages_terminate_build   0

### Work-around the fact that OpenSUSE/SLES _always_ defined both :-/
%if 0%{?sles_version} == 0
%undefine sles_version
%endif

Summary: DRLM
Name: drlm
Version: 2.4.0
Release: 1%{?rpmrelease}%{?dist}
License: GPLv3
Group: Applications/File
URL: http://drlm.org/

Source: http://github.com/brainupdaters/drlm/

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildArch: noarch

### Dependencies on all distributions
Requires: openssl
Requires: gzip tar
Requires: gawk sed grep
Requires: coreutils util-linux
Requires: rpcbind
Requires: rsync

### SUSE packages
%if %{?suse_version:1}0
Requires: openssh
Requires: qemu-tools
Requires: tftp		
Requires: dhcp-server		
Requires: nfs-kernel-server
Requires: lsb-release
Requires: sqlite3
%endif

### RHEL/Fedora/Centos packages
%if (0%{?centos} || 0%{?fedora} || 0%{?rhel})
Requires: openssh-clients
Requires: tftp-server
Requires: qemu-img
Requires: crontabs
Requires: redhat-lsb-core
Requires: nfs-utils
Requires: sqlite
%endif

%if (0%{?centos} <= 7 || 0%{?rhel} <= 7)
Requires: dhcp
%else
Requires: dhcp-server
%endif

#Obsoletes:

%description
Disaster Recovery Linux Manager (DRLM) is a Centralized Management
Open Source solution for small-to-large Disaster Recovery implementations
using ReaR.

Is an easy-to-use software to manage your growing ReaR infrastructure.
Is written in the Bash language (like ReaR) and offers all needed tools to
efficiently manage your GNU/Linux disaster recovery backups,
reducing Disaster Recovery management costs.

ReaR is great solution, but when we're dealing with hundreds of systems,
could be complex to manage well all ReaR deployments.
With DRLM you can, easily and centrally, deploy and manage ReaR installations
for all your GNU/Linux systems in your DataCenter(s).

DRLM is able to manage all required services (TFTP, DHCP-PXE, NFS, ...) with
no need of manual services configuration. Only with few easy commands,
the users will be able to create, modify and delete ReaR clients and networks,
providing an easy way to boot and recover your GNU/Linux systems over
the network with ReaR.

Furthermore DRLM acts as a central scheduling system for all ReaR installations.
Is able to start rear backups remotely and store the rescue-boot/backup in
DR images easily managed by DRLM.

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

%pre
### If --> is upgrade save old data and stop systemd services
if [ "$1" == "2" ]; then

drlm_ver="$(awk 'BEGIN { FS="=" } /^VERSION=/ { print $$2}' /usr/sbin/drlm)"
mv /var/lib/drlm/drlm.sqlite /var/lib/drlm/$drlm_ver-drlm.sqlite.save

systemctl is-active --quiet drlm-stord.service && systemctl stop drlm-stord.service
systemctl is-enabled --quiet drlm-stord.service && systemctl disable drlm-stord.service

systemctl is-active --quiet drlm-api.service && systemctl stop drlm-api.service
systemctl is-enabled --quiet drlm-api.service && systemctl disable drlm-api.service

systemctl is-active --quiet drlm-rsyncd.service && systemctl stop drlm-rsyncd.service
systemctl is-enabled --quiet drlm-rsyncd.service && systemctl disable drlm-rsyncd.service

systemctl is-active --quiet drlm-tftpd.service && systemctl stop drlm-tftpd.service
systemctl is-enabled --quiet drlm-tftpd.service && systemctl disable drlm-tftpd.service

systemctl daemon-reload
fi

%post
### Create client config directory
[ ! -d /etc/drlm/clients ] && mkdir /etc/drlm/clients
[ ! -d /etc/drlm/alerts ] && mkdir /etc/drlm/alerts
chmod 700 /etc/drlm

### Create directory for rear client logs
[ ! -d /var/log/drlm/rear ] && mkdir -p /var/log/drlm/rear
chmod 775 /var/log/drlm/rear

### Check if /etc/exports.d directory is present
[ ! -d /etc/exports.d ] && mkdir -p /etc/exports.d && chmod 755 /etc/exports.d

### Check if /etc/rsyncd.d directory is present
[ ! -d /etc/drlm/rsyncd/rsyncd.d ] && mkdir /etc/drlm/rsyncd/rsyncd.d && chmod 755 /etc/drlm/rsyncd/rsyncd.d

### Unpack GRUB files
tar --no-same-owner -xzf /var/lib/drlm/store/boot/grub/grub2.04rc1_drlm_i386-pc_i386-efi_x86_64-efi_powerpc-ieee1275.tgz -C /var/lib/drlm/store/boot/grub
chmod 700 /var/lib/drlm/store

### If --> is install create keys
if [ "$1" == "1" ]; then
openssl req -newkey rsa:4096 -nodes -keyout /etc/drlm/cert/drlm.key -x509 -days 1825 -subj "/C=ES/ST=CAT/L=GI/O=SA/CN=$(hostname -s)" -out /etc/drlm/cert/drlm.crt
### Else --> is update save keys
else
  if [ -f /etc/drlm/cert/drlm.key ]; then
    mv /etc/drlm/cert/drlm.key /etc/drlm/cert/tmp_drlm.key
  fi
  if [ -f /etc/drlm/cert/drlm.crt ]; then
    mv /etc/drlm/cert/drlm.crt /etc/drlm/cert/tmp_drlm.crt
  fi
fi

### Create tftp user
if ! getent passwd tftp > /dev/null 2>&1; then 
  adduser --system --home-dir /var/lib/drlm/store --no-create-home --comment 'tftp daemon' --user-group tftp
fi

### Generate Database
/usr/share/drlm/conf/DB/drlm_db_version.sh

### Configure nbd
/usr/share/drlm/conf/nbd/config-nbd.sh install

### Configure DHCP
/usr/share/drlm/conf/DHCP/config-DHCP.sh install

### Enable systemd services 
echo "NFS_SVC_NAME=\"nfs-server\"" >> /etc/drlm/local.conf
systemctl enable rpcbind.service
systemctl enable nfs-server.service
systemctl enable dhcpd.service

### If is upgrade from older DRLM versions is important stop https server
if [ "$1" == "2" ]; then
%if %{?suse_version:1}0
systemctl is-active --quiet apache2.service && systemctl stop apache2.service
systemctl is-enabled --quiet apache2.service && systemctl disable apache2.service
%endif
%if (0%{?centos} || 0%{?fedora} || 0%{?rhel})
systemctl is-active --quiet httpd.service && systemctl stop httpd.service
systemctl is-enabled --quiet httpd.service && systemctl disable httpd.service
%endif
fi

### Save drlm-stord.service
%{__cp} /usr/share/drlm/conf/systemd/drlm-stord.service /etc/systemd/system/tmp_drlm-stord.service
%{__cp} /usr/share/drlm/conf/systemd/drlm-api.service /etc/systemd/system/tmp_drlm-api.service
%{__cp} /usr/share/drlm/conf/systemd/drlm-rsyncd.service /etc/systemd/system/tmp_drlm-rsyncd.service
%{__cp} /usr/share/drlm/conf/systemd/drlm-tftpd.service /etc/systemd/system/tmp_drlm-tftpd.service

### Change TimeoutSec according to systemctl version
%if %(systemctl --version | head -n 1 | cut -d' ' -f2) < 229
%{__sed} -i "s/TimeoutSec=infinity/TimeoutSec=0/g" /etc/systemd/system/tmp_drlm-stord.service
%endif

%preun
### Remove certificates
%{__rm} -f /etc/drlm/cert/drlm.*

### Stop and disable systemd services
systemctl is-active --quiet drlm-stord.service && systemctl stop drlm-stord.service
systemctl is-enabled --quiet drlm-stord.service && systemctl disable drlm-stord.service

systemctl is-active --quiet drlm-api.service && systemctl stop drlm-api.service
systemctl is-enabled --quiet drlm-api.service && systemctl disable drlm-api.service

systemctl is-active --quiet drlm-rsyncd.service && systemctl stop drlm-rsyncd.service
systemctl is-enabled --quiet drlm-rsyncd.service && systemctl disable drlm-rsyncd.service

systemctl is-active --quiet drlm-tftpd.service && systemctl stop drlm-tftpd.service
systemctl is-enabled --quiet drlm-tftpd.service && systemctl disable drlm-tftpd.service

systemctl daemon-reload
%{__rm} -f /etc/systemd/system/drlm-stord.service
%{__rm} -f /etc/systemd/system/drlm-api.service
%{__rm} -f /etc/systemd/system/drlm-rsyncd.service
%{__rm} -f /etc/systemd/system/drlm-tftpd.service

# Unconfigure nbd
/usr/share/drlm/conf/nbd/config-nbd.sh remove

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%doc AUTHORS COPYING README.rst
%doc %{_mandir}/man8/drlm.8*
%config(noreplace) %{_sysconfdir}/drlm/
%config(noreplace) %{_sysconfdir}/cron.d/drlm
%config(noreplace) %{_sysconfdir}/bash_completion.d/drlm_completions
%config(noreplace) %{_sysconfdir}/logrotate.d/drlm
%{_datadir}/drlm/
%config(noreplace) %{_localstatedir}/lib/drlm/
%{_sbindir}/drlm
%{_sbindir}/drlm-stord
%{_sbindir}/drlm-api

%posttrans
### Rcover certificates post transaction
if [ -f /etc/drlm/cert/tmp_drlm.key ]; then
  mv /etc/drlm/cert/tmp_drlm.key /etc/drlm/cert/drlm.key
  mv /etc/drlm/cert/tmp_drlm.crt /etc/drlm/cert/drlm.crt
fi

### Recover and reload services post transaction
if [ -f /etc/systemd/system/tmp_drlm-stord.service ]; then
  mv /etc/systemd/system/tmp_drlm-stord.service /etc/systemd/system/drlm-stord.service
  systemctl is-active --quiet drlm-stord.service && systemctl stop drlm-stord.service
fi

if [ -f /etc/systemd/system/tmp_drlm-api.service ]; then
  mv /etc/systemd/system/tmp_drlm-api.service /etc/systemd/system/drlm-api.service
  systemctl is-active --quiet drlm-api.service && systemctl stop drlm-api.service
fi

if [ -f /etc/systemd/system/tmp_drlm-rsyncd.service ]; then
  mv /etc/systemd/system/tmp_drlm-rsyncd.service /etc/systemd/system/drlm-rsyncd.service
  systemctl is-active --quiet drlm-rsyncd.service && systemctl stop drlm-rsyncd.service
fi

if [ -f /etc/systemd/system/tmp_drlm-tftpd.service ]; then
  mv /etc/systemd/system/tmp_drlm-tftpd.service /etc/systemd/system/drlm-tftpd.service
  systemctl is-active --quiet drlm-tftpd.service && systemctl stop drlm-tftpd.service
fi

systemctl daemon-reload

systemctl is-enabled --quiet drlm-stord.service || systemctl enable drlm-stord.service
systemctl start drlm-stord.service

systemctl is-enabled --quiet drlm-api.service || systemctl enable drlm-api.service
systemctl start drlm-api.service

systemctl is-enabled --quiet drlm-rsyncd.service || systemctl enable drlm-rsyncd.service
systemctl start drlm-rsyncd.service

systemctl is-enabled --quiet drlm-tftpd.service || systemctl enable drlm-tftpd.service
systemctl start drlm-tftpd.service

%changelog

* Tue Apr 20 2021 Pau Roura <pau@brainupdaters.net> 2.4.0
- Multiple configuration supported
- Incremental backups supported
- ISO recover image supported 
- PowerPC architecture supported
- ReaR mkbackuponly and ReaR restoreonly supported
- Configurable DRLM parameters for each client or backup
- Added drlm-api systemd service
- HTTPS GUI base to add future functionalities
- Security token added for comunitacions between DRLM server and client
- Improved and simplified client configurations
- Loop devices are repaced by NBD (network block devices)
- DR file format was changed from RAW to QCOW2 
- Improved instclient configuration workflow
- List Unscheduled clients bug fixed
- Removed unsupported SysVinit service management
- SSH_PORT variable independent of SSH_OPTS
- RSYNC protocol supported
- Improved DRLM installation
- Added drlm-tftpd systemd service
- Added drlm-rsyncd systemd service
- Addnetwork, modnetwork and addclient simplified
- Addnetwork is done automatically when you run addclient
- DHCP server is managed automatically
- Improves logs management

* Mon Dec 28 2020 Pau Roura <pau@brainupdaters.net> 2.3.2
- Fixed wget package dependency (issue #127)
- Fixed make clean leave drlm-api binary in place (issue #130)
- Fixed message errors during drlm version upgrade (issue #131, #132)
- Fixed NFS_OPTS variable is not honored (issue #138)
- RedHat/CentOS 8 support
- Ubuntu 20.04 support

* Wed Jul 03 2019 Néfix Estrada <nefix@brainupdaters.net> 2.3.1
- Fixed DRLM user group permissions (issue #118).
- Fixed copy_ssh_id function with the -u parameter (issue #119).
- Listbackup in pretty mode without OS version / ReaR version works now (issue #120).
- Updated the default configuration.

* Mon Jun 17 2019 Néfix Estrada <nefix@brainupdaters.net> 2.3.0
- Golang DRLM API replacing Apache2 and CGI-BIN.
- Listbackup command now shows size and duration of backup.
- Improved database version control.
- dpkg purge section added.
- Improved disable_nfs_fs function.
- Added "-C" on install workflow to allow configuration of the client without install dependencies.
- Added "-I" in the import backup workflow to allow importing a backup from within the same DRLM server.
- Added "-U" on list clients to list the clients that have no scheduled jobs.
- Added a column on list clients that shows if a client has scheduled jobs.
- Added "-p" on list backups workflow to mark the backups that might have failed with colors.
- Added "-C" on addclient workflow to allow the configuration of the client without installing the dependencies.
- Debian 10 Support on install client workflow.
- Added ReaR 2.5 support on Debian 10, Debian 9, Debian 8, Ubuntu 18, Ubuntu 16, Ubuntu 14, Centos 6 and Centos 7.
- Added OS version and ReaR version in listclient.
- Added "-p" on list clients workflow to mark client status (up/down).
- Installclient workflow install ReaR packages from default.conf by default. Is possible to force to install ReaR from repositories with -r/--repo parameter (issue #114).

* Wed Oct 03 2018 Pau Roura <pau@brainupdaters.net> 2.2.1
- Updated ssh_install_rear_xxx funcitons (issue #62).
- Ubuntu 18.04 support (issue #81).
- Fixed Mac address change not reflected on PXE (issue #65).
- Solve certificate deployment to clients (issue #66).
- Improve sched log cleanups (issue #67).
- Improve addclient and addnetwork database ID allocation (issue #69).
- New variable SSH_PORT has been created on default.conf to allow user to choose the ssh port (issue #70)
- Improve security on HTTP server getting the client config. (issue #76).
- Delete client related jobs in delclient workflow (issue #82).
- Updated timeout for drlm-stord.service (issue #74).
- Modnetwork server ip now modify client.cfg files (issue #77).
- In modnetwork if netmask is not specified is taken database saved netmask.
- In addnetwork if network IP is not specified will be calculated (issue #84).
- Problem with PXE folder file parsing fixed (issue #86).
- Automatically remove DR files after failed backup (issue #90).

* Wed Aug 23 2017 Pau Roura <pau@brainupdaters.net> 2.2.0
- "Make deb" improved deleting residual files.
- NEW Real time clients log in DRLM server.
- NEW bash_completion feature added to facilitate the use.
- It is possible to perform a "rear recover" without the parameters DRLM_SERVER, REST_OPTS and ID.
- listbackup, listclient and listnetwork with "-A" parameter by default.
- SSH_OPTS variable created in default.conf for remove hardcoded ssh options.
- Debian 9 compatibility added.
- Improved client configuration template.
- Improved treatment of deleted client backups

* Fri May 05 2017 Pau Roura <pau@brainupdaters.net> 2.1.3
- Update Debian 6 installclient dependencies.
- Now "apt-get update" is done before "apt-get install" in instclient debian workflow.
- Set global UMASK value for all DRLM creating files durting execution.

* Fri Mar 10 2017 Ruben Carbonell <ruben@brainupdaters.net> 2.1.2
- SUDO_CMDS_DRLM added in default.conf allowing to easy add new sudo.
- Automatic creation of /etc/sudoers.d if not exists RedHat/CentOS 5
- Fixed some errors for dependencies on default.conf.
- DRLM_USER variable deleted on addclient and help.
- Added sudo for stat to allow check size on File Systems without perms.
- Sudo configuration files are dynamically created according to the OS type.
- Solved problem for start services with non root user.

* Mon Feb 20 2017 Pau Roura <pau@brainupdaters.net> 2.1.1
- Solved some bugs.
- No Client ID required for delete backups.
- No Client ID required for delete backups.
- bkpmgr: Persistent mode deleted.
- Solved PXE files: forced console=ttyS0 in kernel options.
- Solved hardcoded PXE filenames (initrd.xz (lzma) now supported).
- While recommended, It ain't mandatory to use hostname as client_name.
- Solved drlm user hardcoded in installclient.
- NAGSRV and NAGPORT added in default.conf.

* Thu Feb 09 2017 Pau Roura <pau@brainupdaters.net> 2.1.0
- DRLM reporting with nsca-ng, nsca.
- DRLM Server for SLES.
- Support for drlm unattended installation (instclient) on Ubuntu.
- NEW Import & Export DR images between DRLM servers.
- Pass DRLM global options to ReaR.
- New DRLM backup job scheduler.
- Addclient install mode (automatize install client after the client creation).
- Solved lots of bugs.

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
