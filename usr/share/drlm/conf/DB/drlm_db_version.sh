#!/bin/bash

drlm_old_ver="0"
drlm_old_file=""
drlm_new_ver="$(awk 'BEGIN { FS="=" } /VERSION=/ { print $$2 }' /usr/sbin/drlm)"

#Loking for old databases, get the newest and convert version to numeric (2.1.10 --> 20110; 2.10.1 --> 21001)     
for file in /var/lib/drlm/*sqlite.save; do
    if [ -f "$file" ]; then
        file=$(basename $file)
        
        drlm_ver_par1=$(echo "$(echo "$file" | cut -d'-' -f 1 | cut -d '.' -f 1)")
        if [ $(echo "$file" | cut -d'-' -f 1 | cut -d '.' -f 2) -lt 10 ]; then
            drlm_ver_par2=$(echo "0$(echo "$file" | cut -d'-' -f 1 | cut -d '.' -f 2)")
        else    
            drlm_ver_par2=$(echo "$(echo "$file" | cut -d'-' -f 1 | cut -d '.' -f 2)")
        fi
        if [ $(echo "$file" | cut -d'-' -f 1 | cut -d '.' -f 3) -lt 10 ]; then
            drlm_ver_par3=$(echo "0$(echo "$file" | cut -d'-' -f 1 | cut -d '.' -f 3)")
        else    
            drlm_ver_par3=$(echo "$(echo "$file" | cut -d'-' -f 1 | cut -d '.' -f 3)")
        fi

        if [ $(echo ${drlm_ver_par1}${drlm_ver_par2}${drlm_ver_par3}) -gt $drlm_old_ver ]; then 
            drlm_old_ver=$(echo ${drlm_ver_par1}${drlm_ver_par2}${drlm_ver_par3})
            drlm_old_file=$file
        fi
    fi
done

#if no old database create a new one, else update.  
if [ $drlm_old_ver -eq 0 ]; then
    /usr/bin/sqlite3 /var/lib/drlm/drlm.sqlite < /usr/share/drlm/conf/DB/drlm_sqlite_schema.sql
else
    cp  /var/lib/drlm/$drlm_old_file /var/lib/drlm/drlm.sqlite

    if [ $drlm_old_ver -lt 20000 ]; then
        /usr/bin/sqlite3 /var/lib/drlm/drlm.sqlite < /usr/share/drlm/conf/DB/2.0.0_db_update.sql
    fi
    if [ $drlm_old_ver -lt 20100 ]; then
        /usr/bin/sqlite3 /var/lib/drlm/drlm.sqlite < /usr/share/drlm/conf/DB/2.1.0_db_update.sql
    fi
    if [ $drlm_old_ver -lt 20200 ]; then
        /usr/bin/sqlite3 /var/lib/drlm/drlm.sqlite < /usr/share/drlm/conf/DB/2.2.0_db_update.sql
    fi
    if [ $drlm_old_ver -lt 20300 ]; then
        /usr/bin/sqlite3 /var/lib/drlm/drlm.sqlite < /usr/share/drlm/conf/DB/2.3.0_db_update.sql
    fi
    if [ $drlm_old_ver -lt 20400 ]; then
        /usr/bin/sqlite3 /var/lib/drlm/drlm.sqlite < /usr/share/drlm/conf/DB/2.4.0_db_update.sql
        
        /usr/bin/sqlite3 /var/lib/drlm/drlm.sqlite "select * from backups" | while read backup_line; do
          BKP_ID="$(echo $backup_line | awk -F"|" '{print $1}')"
          BKP_DATE="$(echo $BKP_ID | awk -F"." '{print $2}' | cut -c1-12 )"
          /usr/bin/sqlite3 /var/lib/drlm/drlm.sqlite "update backups set date='$BKP_DATE' where idbackup='$BKP_ID';"
        done
    fi
    if [ $drlm_old_ver -lt 20402 ]; then
        /usr/bin/sqlite3 /var/lib/drlm/drlm.sqlite < /usr/share/drlm/conf/DB/2.4.2_db_update.sql
    fi
fi

# Update drlm.sqlite permissions
chmod 600 /var/lib/drlm/drlm.sqlite
