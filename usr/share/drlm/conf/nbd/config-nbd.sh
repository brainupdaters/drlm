#!/bin/bash

if [ -f /usr/share/drlm/conf/rsync/rsync-status.conf ]; then
  source /usr/share/drlm/conf/rsync/rsync-status.conf
fi

case $1 in
  "install")

    ;;

  "uninstall")

    ;;

  "purge")

    ;;
    
esac