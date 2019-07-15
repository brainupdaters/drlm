FROM debian:buster-slim

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Add package dependencies to build drlm
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    git build-essential debhelper golang fakeroot \
    apt-transport-https ca-certificates && \
    # Clean rootfs
    apt-get clean all && \
    apt-get autoremove -y && \
    apt-get purge && \
    rm -rf /var/lib/{apt,dpkg,cache,log} && \
    update-ca-certificates 

# GIT clone drlm repo
RUN git clone https://github.com/brainupdaters/drlm -b develop tmp/drlm

# Make Debian DEB for final DRLM image
RUN cd /tmp/drlm; make deb

# Build final DRLM image with built DEB

FROM debian:buster-slim

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        isc-dhcp-server \
        tftpd-hpa \
        nfs-kernel-server \
        openssh-client openssl bash-completion procps \
        wget gawk qemu-utils sqlite3 lsb-release \
        iproute2 cpio file iputils-ping nvi && \
    # Clean rootfs
    apt-get clean all && \
    apt-get autoremove -y && \
    apt-get purge && \
    rm -rf /var/lib/{apt,dpkg,cache,log} && \
    # Configure DHCP
    touch /var/lib/dhcp/dhcpd.leases && \
    # Configure rpcbind
    mkdir -p /run/sendsigs.omit.d && \
    touch /run/sendsigs.omit.d/rpcbind

COPY --from=0 /tmp/drlm*.deb .

RUN dpkg -i drlm*.deb; \
    mkdir /etc/drlm-default; \
    cp -r /etc/drlm /etc/drlm-default; \
    rm -f drlm*.deb

# Export the NFS server ports
EXPOSE 111/tcp \
       111/udp \
       2049/tcp \
       2049/udp \
       67/tcp \
       67/udp \
       69/udp

WORKDIR /

VOLUME ["/etc/dhcp"]
VOLUME ["/etc/default"]

COPY entrypoint.sh /entrypoint.sh
    # Set correct entrypoint permission
RUN chmod u+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
