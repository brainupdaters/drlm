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

  * Multiarch netboot client support (x86_64-efi, i386-efi, i386-pc)

  * Automatic client intallation from DRLM server

  * Parallel backups

  * Error reporting support to:

      - HP OpenView

      - Nagios (NSCA & NSCA-ng) (NEW!)

      - Zabbix

      - Mail

  * Centralized backup scheduling with a job scheduler (NEW!)

  * Export and Import backup between DRLM servers or DRLM clients (NEW!)


NOTE: Features marked experimental are prone to change with future releases.


DRLM Releases
-------------

The first release of DRLM, version 1.0.0, was posted to the web in
December 2013. For each release, this chapter lists the new features and defect
fixes. Note that all releases are cumulative, and that all releases of
DRLM are compatible with previous versions, unless otherwise noted.

The references pointing to fix #nr or issue #nr refer to our issues tracker

DRLM Version 2.2.0 (June 2017) - Release Notes
-----------------------------------------------

  * "Make deb" improved deleting residual files.

  * NEW Real time clients log in DRLM server.

  * NEW bash_completion feature added to facilitate the use.

  * It is possible to perform a "rear recover" without the parameters DRLM_SERVER, REST_OPTS and ID.

  * listbackup, listclient and listnetwork with "-A" parameter by default.

  * SSH_OPTS variable created in default.conf for remove hardcoded ssh options.

  * Debian 9 compatibility added.

DRLM Version 2.1.3 (May 2017) - Release Notes
-----------------------------------------------

  * Update Debian 6 installclient dependencies. (issue #57)

  * Now "apt-get update" is done before "apt-get install" in instclient debian workflow.

  * Set global UMASK value for all DRLM creating files durting execution.

DRLM Version 2.1.2 (March 2017) - Release Notes
-----------------------------------------------

  * SUDO_CMDS_DRLM added in default.conf allowing to easy add new sudo commands.

  * Automatic creation of /etc/sudoers.d if not exists on systems RedHat/CenOS 5.

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
  * Debian 7 and 8
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
