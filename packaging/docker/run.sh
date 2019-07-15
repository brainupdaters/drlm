#!/bin/bash

DOCKER_DIR=${PWD}/packaging/docker

source ${DOCKER_DIR}/env.conf

IS_MODULE=`lsmod | grep -o nfsd`
if [[ -z "${IS_MODULE}" ]]; then
	echo "${0}: Missing module nfsd: probing now..."
	sudo modprobe nfsd
fi

if [[ ${USE_PORT_MAPPING} != 0 ]]; then
    DOCKER_NETWORK="-p ${PORT_111_TCP}:111/tcp \
                    -p ${PORT_111_UDP}:111/udp \
                    -p ${PORT_2049_TCP}:2049/tcp \
                    -p ${PORT_2049_UDP}:2049/udp \
                    -p ${PORT_67_TCP}:67/tcp \
                    -p ${PORT_67_UDP}:67/udp \
                    -p ${PORT_69_UDP}:69/udp"
    echo "${0}: Using Docker port mapping."
else
    DOCKER_NETWORK="--network=host"
    echo "${0}: Using Docker Host network mode."
fi

# --name=nfs
docker run --name=drlm-server --rm -t -d --privileged \
${DOCKER_NETWORK} \
-v ${TFTP_DIR}:/var/lib/drlm/store \
-v ${ARCHIVE_DIR}:/var/lib/drlm/arch \
-v ${DRLM_ROOT_DIR}:/var/lib/drlm \
-v ${NFS_DIR}:/nfs \
-v ${DRLM_CONF_DIR}/drlm:/etc/drlm \
-v ${DRLM_CONF_DIR}/exports:/etc/exports \
-v ${DRLM_CONF_DIR}/default/nfs-kernel-server:/etc/default/nfs-kernel-server \
-v ${DRLM_CONF_DIR}/default/isc-dhcp-server:/etc/default/isc-dhcp-server \
-v ${DRLM_CONF_DIR}/dhcp/dhcpd-conf:/etc/dhcp/dhcpd.conf \
-v ${DRLM_CONF_DIR}/network/interfaces:/etc/network/interfaces \
${DOCKER_IMAGE}:${DOCKER_TAG}
