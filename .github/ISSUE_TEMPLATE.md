#### Disaster Recovery Linux Manager (DRLM) Issue Template

###### Quick response time is not guaranteed with free support, if you are using DRLM in a production environment and enterprise grade level support services are required, please see: http://www.brainupdaters.net/en/drlm-services.

Please fill in the following items before submitting a new issue:

##### Issue details:

* Issue type (**Bug** / **Question** / **Feature Request** / **Others?**):
* Impact (**Low** / **High** / **Critical** / **Urgent**):
* How often it happens (**Always** / **Eventually**):
* Brief description of the issue:
* Work-around, if any:

##### DRLM Server information:

* DRLM version (/usr/sbin/drlm -V):
* OS version (cat /etc/drlm/os.conf or lsb_release -a):
* DRLM configuration files output: 
  * cat /etc/drlm/local.conf
  * cat /etc/drlm/clients/**client_name**.cfg

* DRLM error reporting configuration output (if applicable):
  * more /etc/drlm/alerts/*.cfg
  
* Output of: 
  * drlm listclient -c **client_name**
  * drlm listnetwork -A
  
##### DRLM Client information:

* ReaR version (/usr/sbin/rear -V):
* OS version (cat /etc/rear/os.conf or lsb_release -a):
* ReaR configuration files (cat /etc/rear/site.conf or cat /etc/rear/local.conf):
* Hardware platform (uname -i):
  * In case of i386/i686 or x86_64 platforms, BIOS or UEFI?
