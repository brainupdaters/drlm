DRLM - Disaster Recovery Linux Manager
======================================

Disaster Recovery Linux Manager (DRLM) is a Central Management Open Source
Software for Linux Disaster Recovery and System Migrations, based on
Relax-and-Recover (ReaR).

DRLM provides Central Management and Deployment from small to large
Linux Disaster Recovery Implementations bringing a great Centralized Management
Tool to Linux SysAdmins.

With DRLM SysAdmins can add/delete/modify networks and ReaR clients to manage,
run backups and enable/disable Disaster Recovery system images to recovery
through network.

`Professional services and support are available
<http://www.brainupdaters.net/en/drlm-services/>`_.

For more detailed information about Disaster Recovery Linux Manager, please
read the Disaster Recovery Linux Manager `Project Web Page
<http://www.drlm.org/>`_.


REQUIREMENTS
------------

As DRLM has been solely written in the bash language we need the
bash shell which is standard available on all GNU/Linux based systems.

Also requires some system services in order to work properly:

  * isc-dhcpd
  * nfs-server
  * tftpd
  * qemu-img
  * sqlite3

All other required programs (like sort, dd, grep, etc.) are so common, that
we don't list them as requirements. In case your specific workflow requires
additional tools, Disaster Recovery Linux Manager will tell you.

DRLM is a tool to manage REAR systems, so all clients need REAR package and
its dependencies to work properly.

For detailed documentation of DRLM and all system and software requirements,
please visit: http://docs.drlm.org


INSTALLATION
------------

On RPM based systems you should use the drlm RPM package. Either obtain it
from the DRLM homepage or build it yourself from the source
tree with:
::

  $ make rpm

This will create an RPM for your distribution. The RPM is not platform-
dependant and should work also on other RPM based distributions.

On DEB based systems you can execute the command:
::

  $ make deb

For more information about Disaster Recovery Linux Manager installation,
please read the Disaster Recovery Linux Manager `Documentation Page
<http://docs.drlm.org/>`_.

On a Docker environment you can execute the command:
::

  $ make docker

Docker engine 17.04+ needs to be installed on the host in order to run the docker container version.
The docker version builds a debian 10 image with required services baked in.

The host running docker engine will require the loops to be increased in:

/etc/default/grub
::
  $ GRUB_CMDLINE_LINUX="quiet max_loop=1024" ##UPDATE THIS LINE


CONFIGURATION
-------------

To configure Disaster Recovery Linux Manager you have to edit the configuration
files in '/etc/drlm/'. All '*.conf' files there are part of the configuration,
but only 'local.conf' are intended for the user configuration.

TFTP, HTTP are the services to be manually configured. The other sevices are
automatically configured through DRLM commands.

To configure the TFTP is needed to be defined the DRLM Store Dir as root and enable
the TFTP service on system startup.

Also is needed increment the loop limit devices in grub config in order to be
able reach all DRLM clients.

For more information about Disaster Recovery Linux Manager configuration,
please read the Disaster Recovery Linux Manager `Documentation Page
<http://docs.drlm.org/>`_.

Docker configurations:

Make sure the docker host has the loop limits increased in the /etc/default/grub!

packaging/docker/etc/default = DHCP and NFS default settings

Change the isc-dhcp-server INTERFACESV4 or V6 setting to the running host listening network interface

Tweak the nfs-kernel-server if required (optional)

packaging/docker/env.conf = DOCKER_IMAGE and DOCKER_TAG names and version change (optional)

Host nfs and tftp locations can be changed to new locations i.e. /mnt/nfs or other external storage

NFS_DIR
TFTP_DIR

Ports for internal container can be customised for each service

Rpcbind

PORT_111_TCP=

Nfs Ports

PORT_2049_TCP

Dhcp

PORT_67

Tftp

PORT_69

Default container name = drlm-server (run.sh)


USAGE
-----

To use Disaster Recovery Linux Manager you always call the main script
'/usr/sbin/drlm':

or

Docker container start and run drlm command:
::

  $ packaging/docker/run.sh - to start the drlm container from the root of build folder

To just run commands in the running container:
::

  $ docker exec -it drlm-server drlm

To stop the container:
::

  $ docker stop drlm-server

::

  # drlm --help
  Usage: drlm [-dDsSvV] COMMAND [-- ARGS...]

  Disaster Recovery Linux Manager comes with ABSOLUTELY NO WARRANTY; for details
  see The GNU General Public License at: http://www.gnu.org/licenses/gpl.html

  Available options:

   -d           debug mode; log debug messages
   -D           debugscript mode; log every function call
   -s           simulation mode; show what scripts drlm would include
   -S           step-by-step mode; acknowledge each script individually
   -v           verbose mode; show more output
   -V           version information

  List of commands:

   addclient       register new client to DB.
   addjob          register new job to DB.
   addnetwork      register new network to DB.
   bkpmgr          manage DRLM backup states.
   delbackup       delete backup and unregister from DB.
   delclient       delete client from DB.
   deljob          delete job from DB.
   delnetwork      delete network from DB.
   expbackup       export backup from DB.
   impbackup       import backup from DB.
   instclient      install client from DRLM
   listbackup      list client backups.
   listclient      list registered clients.
   listjob         list planned jobs.
   listnetwork     list registered networks.
   modclient       modify client properties.
   modnetwork      modify network properties.
   runbackup       run backup and register to DB.
   sched           schedule planned jobs.

  Use 'drlm COMMAND --help' for more advanced commands.
