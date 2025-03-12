# This file is part of drlm-extra for Relax-and-Recover, licensed under the GNU General
# Public License. Refer to the included COPYING for full text of license.

# Setting required environment for DRLM proper function

is_true "$DRLM_MANAGED" || return 0

read -r </proc/cmdline

echo $REPLY | grep -q "drlm="
if [ $? -eq 0 ]; then
    echo "DRLM_MANAGED: Getting updated rescue configuration from DRLM ..."
    drlm_cmdline=( $(echo ${REPLY#*drlm=} | sed 's/drlm=//' | tr "," " ") )
    for i in ${drlm_cmdline[@]}
    do
        if echo $i | grep -q '^id=\|^serverip=\|^server='; then
          eval $i
        fi
    done

    echo "DRLM_MANAGED: Setting updated rescue configuration from DRLM ..."

    test -n "$server" && echo "DRLM_SERVER=$server" >> /etc/rear/rescue.conf
    test -n "$id" && echo "DRLM_ID=$id" >> /etc/rear/rescue.conf
    test -n "$server" && echo 'DRLM_REST_OPTS="-H Authorization:$(cat /etc/rear/drlm.token) -k"' >> /etc/rear/rescue.conf
    test -n "$server" && test -n "$serverip" && echo "$serverip  $server" >> /etc/hosts
    test -n "$server" && sed -i "s/^\(connect = \).*/\1$server:874/" /etc/rear/stunnel/drlm.conf

fi
