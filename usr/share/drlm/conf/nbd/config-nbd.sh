#!/bin/bash

if [ -f /usr/share/drlm/conf/rsync/rsync-status.conf ]; then
  source /usr/share/drlm/conf/rsync/rsync-status.conf
fi

case $1 in
  "install")
    if [ -f /etc/modprobe.d/nbd.conf ]; then
      mv /etc/modprobe.d/nbd.conf /usr/share/drlm/conf/nbd/nbd.conf.options.save
    fi
    echo "options nbd max_part=8 nbds_max=256" > /etc/modprobe.d/nbd.conf

    if [ -f /etc/modules-load.d/nbd.conf ]; then
      mv /etc/modules-load.d/nbd.conf /usr/share/drlm/conf/nbd/nbd.conf.load.save
    fi
    echo "nbd" > /etc/modules-load.d/nbd.conf

    modprobe nbd
    ;;

  "remove")
    # Remove current configuration
    if [ -f /etc/modprobe.d/nbd.conf ]; then
      rm -f /etc/modprobe.d/nbd.conf
    fi

    # Restore configuration if exists
    if [ -f /usr/share/drlm/conf/nbd/nbd.conf.options.save ]; then
      mv /usr/share/drlm/conf/nbd/nbd.conf.options.save /etc/modprobe.d/nbd.conf
    fi

    # Remove current configuration
    if [ -f /etc/modprobe.d/nbd.conf ]; then
      rm -f /etc/modules-load.d/nbd.conf
    fi

    # Restore configuration if exists
    if [ -f /usr/share/drlm/conf/nbd/nbd.conf.load.save ]; then
      mv /usr/share/drlm/conf/nbd/nbd.conf.load.save /etc/modules-load.d/nbd.conf
    else
      modprobe -r nbd
    fi  
    ;;
    
esac