# In some dists (e.g. Ubuntu) bash is not the default shell. Statements like 
#   cp -a etc/drlm/{mappings,templates} ...
# assumes bash. So its better to set SHELL
SHELL=/bin/bash

DESTDIR =
OFFICIAL =

### Get version from DRLM itself
drlmbin = usr/sbin/drlm
drlm_store_svc = etc/init.d/drlm-stord
name = drlm
version := $(shell awk 'BEGIN { FS="=" } /^VERSION=/ { print $$2}' $(drlmbin))

### Get the branch information from git
ifeq ($(OFFICIAL),)
ifneq ($(shell which git),)
git_date := $(shell git log -n 1 --format="%ai")
git_ref := $(shell git symbolic-ref -q HEAD)
ifeq ($(word 3,$(subst /, ,$(git_ref))),release)
git_branch = release/$(lastword $(subst /, ,$(git_ref)))
else
ifeq ($(word 3,$(subst /, ,$(git_ref))),feature)
git_branch = feature/$(lastword $(subst /, ,$(git_ref)))
else
git_branch = $(lastword $(subst /, ,$(git_ref)))
endif
endif
endif
else
git_branch = drlm-$(version)
endif
git_branch ?= master

date := $(shell date --date="$(git_date)" +%Y%m%d%H%M)
release_date := $(shell date --date="$(git_date)" +%Y-%m-%d)

prefix = /usr
sysconfdir = /etc
sbindir = $(prefix)/sbin
datadir = $(prefix)/share
mandir = $(datadir)/man
localstatedir = /var

specfile = packaging/rpm/$(name).spec
dscfile = packaging/debian/$(name).dsc

distversion = $(version)
debrelease = 0
rpmrelease = %nil
ifeq ($(OFFICIAL),)
    distversion = $(version)-git
    debrelease = git
    rpmrelease = git
endif

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
	rm -f $(name)-$(distversion).tar.gz
	rm -f build-stamp

### You can call 'make validate' directly from your .git/hooks/pre-commit script
validate:
	@echo -e "\033[1m== Validating scripts and configuration ==\033[0;0m"
	find etc/ usr/share/drlm/conf/ -name '*.conf' | xargs bash -n
	bash -n $(drlmbin)
	find . -name '*.sh' | xargs bash -n

man: doc/drlm.8
	
doc:
	@echo -e "\033[1m== Prepare documentation ==\033[0;0m"

ifneq ($(git_date),)
rewrite:
	@echo -e "\033[1m== Rewriting $(specfile), $(dscfile) and $(drlmbin) ==\033[0;0m"
	sed -i.orig \
		-e 's#^Source:.*#Source: https://future_drlm_website/drlm/${version}/$(name)-${distversion}.tar.gz#' \
		-e 's#^Version:.*#Version: $(version)#' \
		-e 's#^%define rpmrelease.*#%define rpmrelease $(rpmrelease)#' \
		-e 's#^%setup.*#%setup -q -n $(name)-$(distversion)#' \
		$(specfile)
	sed -i.orig \
		-e 's#^Version:.*#Version: $(version)-$(debrelease)#' \
		$(dscfile)
	sed -i.orig \
		-e 's#^VERSION=.*#VERSION=$(distversion)#' \
		-e 's#^RELEASE_DATE=.*#RELEASE_DATE="$(release_date)"#' \
		$(drlmbin)

restore:
	@echo -e "\033[1m== Restoring $(specfile) and $(drlmbin) ==\033[0;0m"
	mv -f $(specfile).orig $(specfile)
	mv -f $(dscfile).orig $(dscfile)
	mv -f $(drlmbin).orig $(drlmbin)
else
rewrite:
	@echo "Nothing to do."

restore:
	@echo "Nothing to do."
endif

install-config:
	@echo -e "\033[1m== Installing configuration ==\033[0;0m"
	install -d -m0700 $(DESTDIR)$(sysconfdir)/drlm/
	install -d -m0600 $(DESTDIR)$(sysconfdir)/drlm/cert
	install -d -m0600 $(DESTDIR)$(sysconfdir)/drlm/clients
	install -d -m0600 $(DESTDIR)$(sysconfdir)/drlm/alerts
	install -Dp -m0600 etc/drlm/cert/drlm.crt $(DESTDIR)$(sysconfdir)/drlm/cert/drlm.crt
	install -Dp -m0600 etc/drlm/cert/drlm.key $(DESTDIR)$(sysconfdir)/drlm/cert/drlm.key
	-[[ ! -e $(DESTDIR)$(sysconfdir)/drlm/local.conf ]] && \
		install -Dp -m0600 etc/drlm/local.conf $(DESTDIR)$(sysconfdir)/drlm/local.conf
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
	@echo -e "\033[1m== Installing store service ==\033[0;0m"
	install -Dp -m0755 $(drlm_store_svc) $(DESTDIR)$(sysconfdir)/init.d/drlm-stord

install-data:
	@echo -e "\033[1m== Installing scripts ==\033[0;0m"
	install -d -m0755 $(DESTDIR)$(datadir)/drlm/
	cp -a usr/share/drlm/. $(DESTDIR)$(datadir)/drlm/
	-find $(DESTDIR)$(datadir)/drlm/ -name '.gitignore' -exec rm -rf {} \; &>/dev/null

install-var:
	@echo -e "\033[1m== Installing working directory ==\033[0;0m"
	install -d -m0755 $(DESTDIR)$(localstatedir)/lib/drlm/
	install -d -m0755 $(DESTDIR)$(localstatedir)/log/drlm/
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

dist: clean validate man rewrite $(name)-$(distversion).tar.gz restore

$(name)-$(distversion).tar.gz:
	@echo -e "\033[1m== Building archive $(name)-$(distversion) ==\033[0;0m"
	git checkout $(git_branch)
	git ls-tree -r --name-only --full-tree $(git_branch) | \
		tar -czf $(name)-$(distversion).tar.gz --transform='s,^,$(name)-$(distversion)/,S' --files-from=-

rpm: dist
	@echo -e "\033[1m== Building RPM package $(name)-$(distversion) ==\033[0;0m"
	rpmbuild -tb --clean \
		--define "_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm" \
		--define "debug_package %{nil}" \
		--define "_rpmdir %(pwd)" $(name)-$(distversion).tar.gz

deb: dist
	@echo -e "\033[1m== Building DEB package $(name)-$(distversion) ==\033[0;0m"
	cp -r packaging/debian/ .
	chmod 755 debian/rules
	fakeroot debian/rules clean
	fakeroot dh_install
	fakeroot debian/rules binary
	-rm -rf debian/
