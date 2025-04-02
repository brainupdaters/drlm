Disaster Recvovery Linux Manager (DRLM)
=======================================

This document contains the release notes for the open source project
Disaster Recovery Linux Manager (DRLM).


Overview
--------

Disaster Recovery Linux Manager (DRLM) is a Central Management Open Source
Software for Linux Disaster Recovery and System Migrations, based on
Relax-and-Recover (ReaR).
DRLM provides Central Management and Deployment from small to large Linux
Disaster Recovery Implementations bringing a great Centralized Management
Tool to Linux SysAdmins.


Product Features
----------------

The following features are supported on the most recent releases of
DRLM. Anything labeled as (NEW!) was added as the most recent
release. New functionality for previous releases can be seen in the next
chapter that details each release.

  * Hot maintenance capability. A client backup can be made online
    while the system is running.

  * Command line interface. DRLM doesnot require a graphical
    interface to run. (console is enough).

  * Multiarch netboot client support (x86_64-efi, i386-efi, i386-pc, powerpc-ieee1275)

  * Automatic client intallation from DRLM server

  * Parallel backups

  * Error reporting support to:

      - HP OpenView

      - Nagios (NSCA, NSCA-ng & NRDP)

      - Zabbix

      - Mail

      - XML/JSON

      - Telegram

  * Centralized backup scheduling with a job scheduler and backup policy

  * Export and Import backup between DRLM servers or DRLM clients

  * Real time clients log in DRLM server


NOTE: Features marked experimental are prone to change with future releases.


DRLM Releases
-------------

The first release of DRLM, version 1.0.0, was posted to the web in
December 2013. For each release, this chapter lists the new features and defect
fixes. Note that all releases are cumulative, and that all releases of
DRLM are compatible with previous versions, unless otherwise noted.

The references pointing to fix #nr or issue #nr refer to our issues tracker

DRLM Version 2.4.13 (April 2025) - Release Notes
---------------------------------------------------
  * NEW! Added support for ReaR 2.9

  * Bugfix in bash_completion if not root

  * Updated bash_completion (sync options)

  * Update drlm setup ReaR rescue script TLS transport

  * Bugfix unmounting DR files. Sync writes before unmounting.

  * Updated database snaps tables

  * Updated RPM dependencies

  * Improved Makefile to manage versions


DRLM Version 2.4.12 (February 2025) - Release Notes
---------------------------------------------------
  * Bugfix in listbackup when no backups are available

  * Bugfix in listclient when no clients are available

  * Bugfix in listnetwork when no networks are available

  * Bugfix in listjob when no jobs are available 

  * NEW! Virtual IP support to backup active cluster services

  * Removed unmaintained Docker support
  
  * NEW! Backup Policy support 

  * Bugfix in API listing holded snaps

  * NEW! Ubuntu 24.04 client & server support

  * NEW! Configurable extra partition size on runbackup

  * Improvement in remove_client_scripts. Avoid removal of other content.

  * Bugfix storing logs in incremental backups

  * NEW! Added TLS secure transport to DRLM rsync Backups

  * NEW! Added ReaR restorefiles workflow

  * NEW! Added DRLM restore workflow

  * NEW! Added drlm-extra interface to patch/extend rear integrations

  * NEW! Added new client git install method as default. (-r/-U keeps old style install)

  * Updated install script

  * NEW! Added support for AlmaLinux, Oracle, OpenSUSE Fedora clients

  * NEW! DRLM can backup itself with internal client.

  * Bugfix in ssh key location

  * Updated ReaR to 2.8

  * Bugfix in make package, drlm-gitd-hook added.

  * Added basics for the enterprise version functionalities (archive, oci, scan & sync)


DRLM Version 2.4.11 (March 2024) - Release Notes
------------------------------------------------
  * NEW! RAWDISK output backup type supported

  * Updated Suse 15 ReaR repositories

  * Bugfix in web, holded backups are not shown

  * New install script

  * Bugfix in installclient adding network interface

  * Check client shell before installclient

  * Bugfix in DRLM pre and post runbackup script

  * Added ability to adjust client configs upon migrations on rescue startup

  * Added ReaR tunning to avoid mac mapping on automatic restore

  * NEW! Telegram error reporting supported

  * NEW! Configurable error reporting message

  * NEW! Toggle pretty mode from command line in all lists

  * Bugfix in get_client_used_mb

  * Bugfix in Debian12 scheduled jobs
  
  * Bugfix in install clients, force non-interactive installations


DRLM Version 2.4.10 (February 2023) - Release Notes
---------------------------------------------------
  * Bugfix in installclient tunnig_rear function

  * Bugfix avoid duplicate settings in /etc/drlm/local.conf during update or install process

  * Bugfix in user deletion to skip error code 12

  * NEW! XML/JSON error reporting supported

  * Bugfix in impbackup client configuration

  * Bugfix runbackup umounting previous backups 

  * Bugfix runbackup rsync hidden warning errors


DRLM Version 2.4.9 (December 2022) - Release Notes
--------------------------------------------------
  * Bugfix in importbackup Debian nbd detach
  
  * Bugfix getting Client OS version fixed

  * Bugfix sending DRLM server hostname

  * Bugfix getting SSH_ROOT_PASSWORD from local.conf or site.conf


DRLM Version 2.4.8 (November 2022) - Release Notes
--------------------------------------------------
  * RedHat 5 client support
  
  * Avoiding Debian nbd detach errors with nbd-client


DRLM Version 2.4.7 (November 2022) - Release Notes
--------------------------------------------------
  * Bugfix removing authorized keys
  
  * Bugfix in installclient DRLM Proxy (hostname unreachable)

  * Improved unsched client sql select 

  * Changed default QEMU_NBD_OPTIONS

  * Mutex race solved in nbd assignment

  * Improved network, client, backup and job lists

  * Bugfix in DRLM PROXY ReaR URL generation


DRLM Version 2.4.6 (September 2022) - Release Notes
---------------------------------------------------
  * Bugfix in deb package update


DRLM Version 2.4.5 (July 2022) - Release Notes
----------------------------------------------
  * NEW! Improved jobs list with status feedback

  * NEW! Now is possible to enable and disable Jobs

  * Speedup list client
  
  * Bugfix in addclient (two MACs one IP)

  * Bugfix in addnetwork (two interface for one IP)

  * Improved run sched backups


DRLM Version 2.4.4 (May 2022) - Release Notes
---------------------------------------------
  * Bugfix in installclient, new dependencies added

  * Bugfix in logs maintenance

  * Remove ReaR crontab file in install client

  * Bugfix prevent hostnames from being localhost

  
DRLM Version 2.4.3 (April 2022) - Release Notes
-----------------------------------------------
  * New! RedHat 9 client & server support

  * Bugfix database creation
  
  * Bugfix RedHat services configuration variable


DRLM Version 2.4.2 (April 2022) - Release Notes
-----------------------------------------------
  * NEW! DRLM Proxy added

  * NEW! Ubuntu 22 client & server support

  * NEW! New Hold backup feature

  * Fixed listclient filtered by client

  * Fixed RHEL 8.5 ppc64le instclient dependency (issue #188)

  * drlm-api improvements

  * Log improvements

  * Bugfix importing old backups

  * Bugfix non case-sensitive bash_completion 

  * Bugfix in upgrade drlm

  * Bugfix icreasing partition size


DRLM Version 2.4.1 (February 2022) - Release Notes
--------------------------------------------------
  * Fixed --skip-alias parameter in which command

  * Fixed several typo errors 

  * Fixed cat, grep and xargs bugs

  * Parameterizable qemu-nbd options

  * Fixed udev hang errors


DRLM Version 2.4.0 (October 2021) - Release Notes
--------------------------------------------------
  * Multiple configuration supported
 
  * Incremental backups supported
 
  * ISO recover image supported 

  * PowerPC architecture supported
 
  * ReaR mkbackuponly and ReaR restoreonly supported
 
  * Configurable DRLM parameters for each client or backup
 
  * Added drlm-api systemd service

  * HTTPS GUI base to add future functionalities
 
  * Security token added for comunitacions between DRLM server and client
 
  * Improved and simplified client configurations
 
  * Loop devices are repaced by NBD (network block devices)
 
  * DR file format was changed from RAW to QCOW2 
 
  * Improved instclient configuration workflow
 
  * List Unscheduled clients bug fixed

  * Removed unsupported SysVinit service management

  * SSH_PORT variable independent of SSH_OPTS
  
  * RSYNC protocol supported

  * Improved DRLM installation

  * Added drlm-tftpd systemd service

  * Added drlm-rsyncd systemd service

  * Addnetwork, modnetwork and addclient simplified

  * Addnetwork is done automatically when you run addclient

  * DHCP server is managed automatically

  * Improved logs management

  * Debian 11 Support on install client workflow

  * Rocky Linux 8 server and client support

  * NRDP Nagios support

  * New write and full write mode in bkpmgr workflow

  * Configurable backup status after runbackup (enabled, disabled, write or full-write mode)

  * Information improvements and new one client mode in drlm-stord

  * Encrypted backup files


DRLM Version 2.3.2 (December 2020) - Release Notes
--------------------------------------------------
  * Fixed wget package dependency (issue #127)

  * Fixed make clean leave drlm-api binary in place (issue #130)

  * Fixed message errors during drlm version upgrade (issue #131, #132)

  * Fixed NFS_OPTS variable is not honored (issue #138)

  * RedHat/CentOS 8 support

  * Ubuntu 20.04 support 


DRLM Version 2.3.1 (July 2019) - Release Notes
----------------------------------------------
  * Fixed DRLM user group permissions (issue #118).

  * Fixed copy_ssh_id function with the -u parameter (issue #119).

  * Listbackup in pretty mode without OS version / ReaR version works now (issue #120).

  * Updated the default configuration.


DRLM Version 2.3.0 (June 2019) - Release Notes
----------------------------------------------
  * Golang DRLM API replacing Apache2 and CGI-BIN.

  * Listbackup command now shows size and duration of backup.

  * Improved database version control.

  * dpkg purge section added.

  * Improved disable_nfs_fs function.

  * Added "-C" on install workflow to allow configuration of the client without install dependencies.

  * Added "-I" in the import backup workflow to allow importing a backup from within the same DRLM server.

  * Added "-U" on list clients to list the clients that have no scheduled jobs.

  * Added a column on list clients that shows if a client has scheduled jobs.

  * Added "-p" on list backups workflow to mark the backups that might have failed with colors.

  * Added "-C" on addclient workflow to allow the configuration of the client without installing the dependencies.

  * Debian 10 Support on install client workflow.

  * Added ReaR 2.5 support on Debian 10, Debian 9, Debian 8, Ubuntu 18, Ubuntu 16, Ubuntu 14, Centos 6 and Centos 7.

  * Added OS version and ReaR version in listclient.

  * Added "-p" on list clients workflow to mark client status (up/down).

  * Installclient workflow install ReaR packages from default.conf by default. Is possible to force to install ReaR from repositories with -r/--repo parameter (issue #114).


DRLM Version 2.2.1 (October 2018) - Release Notes
-------------------------------------------------

  * Updated ssh_install_rear_xxx funcitons (issue #62).

  * Ubuntu 18.04 support (issue #81).

  * Fixed Mac address change not reflected on PXE (issue #65).

  * Solve certificate deployment to clients (issue #66).

  * Improve sched log cleanups (issue #67).

  * Improve addclient and addnetwork database ID allocation (issue #69).

  * New variable SSH_PORT has been created on default.conf to allow user to choose the ssh port (issue #70)

  * Improve security on HTTP server getting the client config. (issue #76).

  * Delete client related jobs in delclient workflow (issue #82).

  * Updated timeout for drlm-stord.service (issue #74).

  * Modnetwork server ip now modify client.cfg files (issue #77).

  * In modnetwork if netmask is not specified is taken database saved netmask.

  * In addnetwork if network IP is not specified will be calculated (issue #84).

  * Problem with PXE folder file parsing fixed (issue #86).

  * Automatically remove DR files after failed backup (issue #90).


DRLM Version 2.2.0 (August 2017) - Release Notes
------------------------------------------------

  * "Make deb" improved deleting residual files.

  * NEW Real time clients log in DRLM server.

  * NEW bash_completion feature added to facilitate the use.

  * It is possible to perform a "rear recover" without the parameters DRLM_SERVER, REST_OPTS and ID.

  * listbackup, listclient and listnetwork with "-A" parameter by default.

  * SSH_OPTS variable created in default.conf for remove hardcoded ssh options.

  * Debian 9 compatibility added.

  * Improved client configuration template.

  * Improved treatment of deleted client backups


DRLM Version 2.1.3 (May 2017) - Release Notes
---------------------------------------------

  * Update Debian 6 installclient dependencies. (issue #57)

  * Now "apt-get update" is done before "apt-get install" in instclient debian workflow.

  * Set global UMASK value for all DRLM creating files durting execution.


DRLM Version 2.1.2 (March 2017) - Release Notes
-----------------------------------------------

  * SUDO_CMDS_DRLM added in default.conf allowing to easy add new sudo commands.

  * Automatic creation of /etc/sudoers.d if not exists on systems RedHat/CentOS 5.

  * Fixed some errors for dependencies on default.conf.

  * DRLM_USER variable deleted on addclient and help.

  * Added sudo for command stat to allow check size on File Systems without perms.

  * Sudo configuration files are dynamically created according to the OS type.

  * Solved problem for start services with non root user.


DRLM Version 2.1.1 (February 2017) - Release Notes
--------------------------------------------------

  * Solved some of bugs. (issue #49, #50)

  * No Client ID required for delete backups. (issue #40)

  * No Client ID required for manage backups. (issue #46)

  * bkpmgr: Persistent mode deleted.

  * Solved PXE files: forced console=ttyS0 in kernel options. (issue #52)

  * Solved hardcoded PXE filenames (initrd.xz (lzma) now supported). (issue #52)

  * While recommended, It ain't mandatory to use hostname as client_name. (issue #52)

  * Solved drlm user hardcoded in installclient. (issue #51)

  * NAGSRV and NAGPORT added in default.conf.


DRLM Version 2.1.0 (February 2017) - Release Notes
--------------------------------------------------

  * DRLM reporting with nsca-ng, nsca. (issue #47)

  * DRLM Server for SLES. (issue #45)

  * Support for drlm unattended installation (instclient) on Ubuntu (issue #43)

  * NEW Import & Export DR images between DRLM servers. (issue #39)

  * Pass DRLM global options to ReaR. (issue #37)

  * New DRLM backup job scheduler (issue #35)

  * Addclient install mode (automatize install client after the client creation) (issue #32)

  * Solved lots of bugs


DRLM Version 2.0.0 (July 2016) -  Release Notes
-----------------------------------------------

  * Multiarch netboot with GRUB2 - x86_64-efi i386-efi i386-pc - (issue #2)

  * New installclient workflow (issue #5)

  * Added support for systemd distros - RHEL7 CentOS7 Debian8 - (issue #14)

  * Use bash socket implementation instead of netcat (issue #15)

  * runbackup workflow enhacement with sparse raw images with qemu-img
    reducing backup time and improving management (issue #16)

  * Added support for parallel backups on DRLM (issue #22)

  * Added support for new DB backend sqlite3 (issue #23)

  * Added support for Nagios error reporting (issue #28)

  * Added support for Zabbix error reporting (issue #29)

  * Added support for Mail error reporting (issue #30)

  * Added timeout var for Sqlite in sqlite3-driver.sh for avoiding database locks.

  * Added source of local.conf and site.conf files in drlm-stord

  * Solved lots of bugs

  * DRLM documentation updated to reflect version 2.0 changes


DRLM Version 1.1.3 (February 2016) -  Release Notes
---------------------------------------------------

  * Hotfix 1.1.3 Change default DRLM STORAGE LOCATIONS in default.conf file  (issue #20)

  * Hotfix 1.1.2 Client backup is not disabled when the client is deleted (issue #17)

  * Other minor bugs solved


DRLM Version 1.1.0 (March 2015) -  Release Notes
------------------------------------------------

  * ReaR fully integration with DRLM since rear 1.17 - ReaR issue #522 - (issue #9)

  * Centralized client configuration

  * Other minor bugs solved


DRLM Version 1.0.0 (December 2013) -  Release Notes
---------------------------------------------------

  * Initial stable release

  * Support for HP Openview error reporting


System and Software Requirements
--------------------------------

As DRLM has been solely written in the bash language we need the
bash shell which is standard available on all GNU/Linux based systems.

Also requires some system services in order to work properly:

  * isc-dhcpd
  * nfs-server
  * tftpd
  * apache2
  * qemu-img
  * sqlite3

All other required programs (like sort, dd, grep, etc.) are so common, that
we don't list them as requirements. In case your specific workflow requires
additional tools, Disaster Recovery Linux Manager will tell you.

DRLM is a tool to manage REAR systems, so all clients need REAR package and
its dependencies to work properly.

For detailed documentation of DRLM and all system and software requirements,
please visit: http://docs.drlm.org


Support
-------

Disaster Recovery Linux Manager (DRLM) is an Open Source project under GPLv3
license which means it is free to use and modify. However, the creators of DRLM
have spent many, many hours in development and support. We will only give
free of charge support in our free time (and when work/home balance allows it).

That does not mean we let our user basis in the cold as we do deliver support
as a service (not free of charge).


Supported Operating Systems
---------------------------

DRLM is supported on the following Linux based operating systems:

  * RHEL 6 and 7
  * CentOS 6 and 7
  * Debian 7, 8 and 9
  * Ubuntu 14 and 16
  * SLES 12 SP1

If you require support for any unsupported Linux Operating System you must
acquire a DRLM support contract.


Supported Architectures
-----------------------

DRLM is developed in Bash and should be supported on any type of processor.
If any architecture related problem appears, please open an issue.


Supported DRLM versions
-----------------------

DRLM has a short history (since 2013) but we cannot supported all released
versions. If you have a problem we urge you to install the latest
stable DRLM version or the development version (available on github) before
submitting an issue.

However, we do understand that it is not always possible to install the
latest and greatest version so we are willing to support some previous
versions of DRLM if you have a support contract.


Known Problems and Workarounds
------------------------------

Issue Description: ....

Issue #??? description....

  * Workaround:

See the fix mentioned in issue #???
or
So far there is no workaround for this issue.
