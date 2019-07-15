#!/bin/sh

# Check if there is site.conf setup otherwise copy a default setup
if [ ! -e /etc/drlm/site.conf ];then
cp -r /etc/drlm-default/* /etc/drlm/
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
    service drlm-stord start

    echo "Started..."
    while true; do sleep 1; done

    exit 0
}

start
