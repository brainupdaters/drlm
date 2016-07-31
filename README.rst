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

Professional services and support are available.

For more detailed information about Disaster Recovery Linux Manager, please
read the Disaster Recovery Linux Manager User Guide.


REQUIREMENTS
------------

DRLM is written entirely in Bash and requires some system services in order to
work properly:

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


CONFIGURATION
-------------

To configure Disaster Recovery Linux Manager you have to edit the configuration
files in '/etc/drlm/'. All '*.conf' files there are part of the configuration,
but only 'local.conf' are intended for the user configuration.

TFTP is the only service to be manually configured. The other sevices are
automatically configured through DRLM commands.

To configure the TFTP is nedeed deefine the DRLM Store Dir as root and enable
the TFTP service on system startup.


USAGE
-----

To use Disaster Recovery Linux Manager you always call the main script
'/usr/sbin/drlm':

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
   addnetwork      register new network to DB.
   bkpmgr          manage DRLM backup states.
   delbackup       delete backup and unregister from DB.
   delclient       delete client from DB.
   delnetwork      delete network from DB.
   instclient      install client from DRLM (NEW!)
   listbackup      list client backups.
   listclient      list registered clients.
   listnetwork     list registered networks.
   modclient       modify client properties.
   modnetwork      modify network properties.
   runbackup       run backup and register to DB.


  Use 'drlm COMMAND --help' for more advanced commands.
