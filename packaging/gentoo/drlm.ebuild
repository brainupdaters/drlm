# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v3
# $Header: $

EAPI=4

DESCRIPTION="Disaster Recovery Linux Manager"
HOMEPAGE="http://future_webpage_drlm/"
SRC_URI="mirror://future_webpage_drlm/drlm/drlm/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
#IUSE="udev"

#RDEPEND="net-dialup/mingetty
#	net-fs/nfs-utils
#	sys-apps/iproute2
#	sys-apps/lsb-release
#	sys-apps/util-linux
#	sys-block/parted
#	sys-boot/syslinux
#	virtual/cdrtools
#	udev? ( sys-fs/udev )
#	dev-libs/openssl
#"
RDEPEND=""

src_install () {
#	if use udev; then
#		insinto /lib/udev/rules.d
#		doins etc/udev/rules.d/62-drlm-usb.rules
#	fi

	insinto /etc
	doins -r etc/drlm/

	# copy main script-file and docs
	dosbin usr/sbin/drlm
#	doman usr/share/drlm/doc/drlm.8
	dodoc README

	insinto /usr/share/
	doins -r usr/share/drlm/
}
