# In some dists (e.g. Ubuntu) bash is not the default shell. Statements like
#   cp -a etc/drlm/{mappings,templates} ...
# assumes bash. So its better to set SHELL
SHELL=/bin/bash

DESTDIR =
OFFICIAL =

name = drlm
drlmbin = usr/sbin/drlm
drlm_store_svc = usr/sbin/drlm-stord
drlm_api = usr/sbin/drlm-api
drlm_proxy = usr/sbin/drlm-proxy
drlm_send_error = usr/sbin/drlm-send-error
drlm_gitd_hook = usr/sbin/drlm-gitd-hook

prefix = /usr
sysconfdir = /etc
sbindir = $(prefix)/sbin
datadir = $(prefix)/share
mandir = $(datadir)/man
localstatedir = /var

specfile = packaging/rpm/$(name).spec
dscfile = packaging/debian/$(name).dsc
changelog = packaging/debian/changelog

# Get the version from the drlm binary
base_version := $(shell awk 'BEGIN { FS="=" } /VERSION=/ { print $$2 }' $(drlmbin))
version := $(base_version)
deb_version := $(base_version)
rpmrelease = 1

### Get the branch information from git
ifeq ($(OFFICIAL),)
    ifneq ($(shell which git),)
        git_date := $(shell git log -n 1 --format="%ai")
        release_date := $(shell date --date="$(git_date)" +%Y-%m-%d)
        name_date := $(shell date --date="$(git_date)" +%Y%m%d%H%M)
        git_branch := $(shell git rev-parse --abbrev-ref HEAD)
        head_hash := $(shell git rev-parse --short HEAD)
        ifneq ($(git_branch), master)
            version := $(base_version)-$(git_branch)_$(head_hash)_$(name_date)
            deb_version := $(base_version)-$(git_branch)-$(head_hash)-$(name_date)
            rpmrelease = $(git_branch)_$(head_hash)_$(name_date)
        endif
    endif
endif

.PHONY: show-version
show-version:
	@echo "Version: $(version)"

all:
	@echo "Nothing to build. Use 'make help' for more information."

help:
	@echo -e "DRLM make targets:\n\
\n\
  validate        - Check source code\n\
  install         - Install DRLM (may replace files)\n\
  uninstall       - Uninstall DRLM (may remove files)\n\
  dist            - Create tar file\n\
  deb             - Create DEB package\n\
  rpm             - Create RPM package\n\
\n\
DRLM make variables (optional):\n\
\n\
  DESTDIR=        - Location to install/uninstall\n\
  OFFICIAL=       - Build an official release\n\
"

clean:
	@echo -e "\033[1m== Cleaning up ==\033[0;0m"
	rm -f $(name)-$(version).tar.gz
	rm -f build-stamp
	rm -f usr/sbin/drlm-api
	rm -f usr/sbin/drlm-proxy
	rm -f usr/sbin/drlm-send-error

validate:
	@echo -e "\033[1m== Validating scripts and configuration ==\033[0;0m"

	#Validating BASH Syntax
	find etc/ usr/share/drlm/conf/ -name '*.conf' ! -path etc/drlm/rsyncd/rsyncd.conf | xargs bash -n
	bash -n $(drlmbin)
	bash -n $(drlm_store_svc)
	for file in $$(find . -type f -name '*.sh'); do bash -n $$file || exit 1; done

ifneq ($(shell which gofmt),)
	#Validating GO Syntax
	gofmt $(shell find usr/share/drlm/ -name '*.go') > /dev/null
else
	@echo -e "Warning: gofmt not found, can not validate DRLM Golang code."
endif

man: doc/drlm.8

doc:
	@echo -e "\033[1m== Prepare documentation ==\033[0;0m"

ifneq ($(git_date),)
rewrite:
	@echo -e "\033[1m== Rewriting $(specfile), $(dscfile) and $(drlmbin) ==\033[0;0m"
	sed -i.orig \
		-e 's#^Source:.*#Source: http://drlm.org/download/${version}/$(name)-${version}.tar.gz#' \
		-e 's#^Version:.*#Version: $(base_version)#' \
		-e 's#^%define rpmrelease.*#%define rpmrelease $(rpmrelease)#' \
		-e 's#^%setup.*#%setup -q -n $(name)-$(version)#' \
		$(specfile)
	sed -i.orig \
		-e 's#^Version:.*#Version: $(version)#' \
		$(dscfile)
	sed -i.orig '1s/(\(.*\))/($(deb_version))/' \
		$(changelog)
	sed -i.orig \
		-e 's#VERSION=.*#VERSION=$(version)#' \
		-e 's#RELEASE_DATE=.*#RELEASE_DATE="$(release_date)"#' \
		$(drlmbin)

restore:
	@echo -e "\033[1m== Restoring $(specfile) and $(drlmbin) ==\033[0;0m"
	mv -f $(specfile).orig $(specfile)
	mv -f $(dscfile).orig $(dscfile)
	mv -f $(drlmbin).orig $(drlmbin)
	mv -f $(changelog).orig $(changelog)
else
rewrite:
	@echo "Nothing to do."
restore:
	@echo "Nothing to do."
endif

install-config:
	@echo -e "\033[1m== Installing configuration ==\033[0;0m"
	install -d -m0700 $(DESTDIR)$(sysconfdir)/drlm/
	cp -a etc/drlm/. $(DESTDIR)$(sysconfdir)/drlm/
	install -Dp -m0600 etc/cron.d/drlm $(DESTDIR)$(sysconfdir)/cron.d/drlm
	install -Dp -m0600 etc/bash_completion.d/drlm_completions $(DESTDIR)$(sysconfdir)/bash_completion.d/drlm_completions
	install -Dp -m0600 etc/logrotate.d/drlm $(DESTDIR)$(sysconfdir)/logrotate.d/drlm
	install -d -m0600 $(DESTDIR)$(sysconfdir)/drlm/clients
	install -d -m0600 $(DESTDIR)$(sysconfdir)/drlm/alerts
	-[[ ! -e $(DESTDIR)$(sysconfdir)/drlm/os.conf && -e etc/drlm/os.conf ]] && \
		install -Dp -m0600 etc/drlm/os.conf $(DESTDIR)$(sysconfdir)/drlm/os.conf
	-find $(DESTDIR)$(sysconfdir)/drlm/ -name '.gitignore' -exec rm -rf {} \; &>/dev/null
	@echo -e "\033[1m== Prepare manual ==\033[0;0m"
	install -Dp -m0644 doc/drlm.8 $(DESTDIR)$(mandir)/man8/drlm.8

install-bin:
	@echo -e "\033[1m== Installing binary ==\033[0;0m"
	install -Dp -m0755 $(drlmbin) $(DESTDIR)$(sbindir)/drlm
	sed -i -e 's,^CONFIG_DIR=.*,CONFIG_DIR="$(sysconfdir)/drlm",' \
		-e 's,^SHARE_DIR=.*,SHARE_DIR="$(datadir)/drlm",' \
		-e 's,^VAR_DIR=.*,VAR_DIR="$(localstatedir)/lib/drlm",' \
		$(DESTDIR)$(sbindir)/drlm
	install -Dp -m0755 $(drlm_store_svc) $(DESTDIR)$(sbindir)/drlm-stord
	install -Dp -m0755 $(drlm_api) $(DESTDIR)$(sbindir)/drlm-api
	install -Dp -m0755 $(drlm_proxy) $(DESTDIR)$(sbindir)/drlm-proxy
	install -Dp -m0755 $(drlm_send_error) $(DESTDIR)$(sbindir)/drlm-send-error
	install -Dp -m0755 $(drlm_gitd_hook) $(DESTDIR)$(sbindir)/drlm-gitd-hook

install-data:
	@echo -e "\033[1m== Installing scripts ==\033[0;0m"
	install -d -m0755 $(DESTDIR)$(datadir)/drlm/
	cp -a usr/share/drlm/. $(DESTDIR)$(datadir)/drlm/
	-find $(DESTDIR)$(datadir)/drlm/ -name '.gitignore' -exec rm -rf {} \; &>/dev/null

install-var:
	@echo -e "\033[1m== Installing working directory ==\033[0;0m"
	install -d -m0755 $(DESTDIR)$(localstatedir)/lib/drlm/
	install -d -m0755 $(DESTDIR)$(localstatedir)/log/drlm/
	install -d -m0755 $(DESTDIR)$(localstatedir)/log/drlm/rear/
	cp -a var/lib/drlm/. $(DESTDIR)$(localstatedir)/lib/drlm/
	-find $(DESTDIR)$(localstatedir)/lib/drlm/ -name '.gitignore' -exec rm -rf {} \; &>/dev/null

install-doc:
	@echo -e "\033[1m== Installing documentation ==\033[0;0m"
	make -C doc install
	sed -i -e 's,/etc,$(sysconfdir),' \
		-e 's,/usr/sbin,$(sbindir),' \
		-e 's,/usr/share,$(datadir),' \
		-e 's,/usr/share/doc/packages,$(datadir)/doc,' \
		$(DESTDIR)$(mandir)/man8/drlm.8

install: validate man install-config rewrite install-bin restore install-data install-var

uninstall:
	@echo -e "\033[1m== Uninstalling DRLM ==\033[0;0m"
	-rm -v $(DESTDIR)$(sbindir)/drlm
	-rm -v $(DESTDIR)$(mandir)/man8/drlm.8
	-rm -rv $(DESTDIR)$(datadir)/drlm/
	rm -rv $(DESTDIR)$(sysconfdir)/drlm/
	rm -rv $(DESTDIR)$(localstatedir)/lib/drlm/

drlmapi:
ifneq ($(shell which go),)
	@echo -e "\033[1m== Building DRLM API ==\033[0;0m"
	go get github.com/google/uuid
	go get github.com/mattn/go-sqlite3
	go build -o ./usr/sbin/drlm-api ./usr/share/drlm/www/drlm-api/
else
	@echo -e "No Go binaries detected to build DRLM API, will be copied the builded one"
endif

drlmproxy:
ifneq ($(shell which go),)
	@echo -e "\033[1m== Building DRLM PROXY ==\033[0;0m"
	go get github.com/gorilla/mux
	go build -o ./usr/sbin/drlm-proxy ./usr/share/drlm/www/drlm-proxy/
else
	@echo -e "No Go binaries detected to build DRLM PROXY, will be copied the builded one"
endif

drlmsenderror:
ifneq ($(shell which go),)
	@echo -e "\033[1m== Building DRLM SEND ERROR ==\033[0;0m"
	go build -o ./usr/sbin/drlm-send-error ./usr/share/drlm/www/drlm-send-error/
else
	@echo -e "No Go binaries detected to build DRLM SEND ERROR, will be copied the builded one"
endif

dist: clean validate drlmapi drlmproxy drlmsenderror man rewrite $(name)-$(version).tar.gz

$(name)-$(version).tar.gz:
	@echo -e "\033[1m== Building archive $(name)-$(version) ==\033[0;0m"
	git checkout $(git_branch)
	git ls-tree -r --name-only --full-tree $(git_branch) | \
		tar -czf $(name)-$(version).tar.gz --transform='s,^,$(name)-$(version)/,S' \
		--files-from=- ./usr/sbin/drlm-api ./usr/sbin/drlm-proxy ./usr/sbin/drlm-send-error

rpm: dist restore
	@echo -e "\033[1m== Building RPM package $(name)-$(version) ==\033[0;0m"
	rpmbuild -tb --clean \
		--define "_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm" \
		--define "debug_package %{nil}" \
		--define "_rpmdir %(pwd)" $(name)-$(version).tar.gz
	
deb_backup:
	@echo -e "\033[1m== Backing up $(specfile) and $(drlmbin) ==\033[0;0m"
	cp $(specfile) $(specfile).bkp
	cp $(dscfile) $(dscfile).bkp
	cp $(drlmbin) $(drlmbin).bkp
	cp $(changelog) $(changelog).bkp

deb_restore:
	@echo -e "\033[1m== Restoring $(specfile) and $(drlmbin) ==\033[0;0m"
	mv -f $(specfile).bkp $(specfile)
	mv -f $(dscfile).bkp $(dscfile)
	mv -f $(drlmbin).bkp $(drlmbin)
	mv -f $(changelog).bkp $(changelog)

deb_packer:
	@echo -e "\033[1m== Building DEB package $(name)-$(version) ==\033[0;0m"
	cp -r packaging/debian/ .
	chmod 755 debian/rules
	fakeroot debian/rules clean
	fakeroot dh_install
	fakeroot debian/rules binary
	-rm -rf debian/
	rm $(name)-$(version).tar.gz
	rm build-stamp
	rm usr/sbin/drlm-api
	rm usr/sbin/drlm-proxy
	rm usr/sbin/drlm-send-error

deb: deb_backup dist deb_packer deb_restore

