#!/bin/sh

# Check if drlm configs exists, if not then extract default
# from default install
if [ ! -e /etc/drlm/site.conf ];then
tar xvf /drlm-etc-lib-drlm.tar -C /
else
echo "DRLM config exists no need to extract!"
fi

# We need to re-run the cert generation as hostname will be of built container name
if [ ! -e /etc/drlm/cert/first-install.txt ];then
openssl req -newkey rsa:4096 -nodes -keyout /etc/drlm/cert/drlm.key -x509 -days 1825 -subj "/C=ES/ST=CAT/L=GI/O=SA/CN=$(hostname -s)" -out /etc/drlm/cert/drlm.crt
touch /etc/drlm/cert/first-install.txt
fi

# Make sure we react to these signals by running stop() when we see them - for clean shutdown
# And then exiting
trap "stop; exit 0;" TERM INT

stop()
{
# We're here because we've seen SIGTERM, likely via a Docker stop command or similar
# Let's shutdown cleanly
    echo "SIGTERM caught, terminating process(es)..."
    echo "NFS Terminate..."
    exportfs -uav
    service nfs-kernel-server stop
    echo "TFTP Terminate..."
    service tftpd-hpa stop
    echo "DHCP Terminate..."
    service isc-dhcp-server stop
    echo "DRLM Stord Terminate..."
    service drlm-stord stop

    exit 0
}

start()
{
    echo "Starting services..."
    echo "TFTP init..."
    service tftpd-hpa start
    echo "NFS init..."
    service rpcbind start
    service nfs-common start
    service nfs-kernel-server start
    exportfs -rva
    echo "DRLM Stord Starting..."
    service drlm-stord start

    echo "Started..."
    while true; do sleep 1; done

    exit 0
}

start
