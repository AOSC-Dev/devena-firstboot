#!/bin/make -f

# Suppress leaving and entering messages from make
MAKEFLAGS += --no-print-directory

# Macros for pretty printing
# To use these macros, you can write something like the following in your recipe:
# $(info)"Your Message" $(clr)
# Calling them as functions has various drawbacks, e.g. not able to escape the
# parameter separator and parentheses.
info = echo -e "\033[1;36m >> \033[1;37m"
err = echo -e "\033[1;33m !! \033[1;37m"
clr = "\033[0m"

export info err clr

# Global definitions
# Project directory
TOP := $(CURDIR)

# Location of devena library
DEVENA_LIB_DIR := /usr/lib/devena-firstboot

# Location of the first boot setup script
FIRSTBOOT_DIR := $(DEVENA_LIB_DIR)/first-boot.d

# Location of the kernel update hook scripts
KERNEL_UPDATE_HOOK_DIR := $(DEVENA_LIB_DIR)/kernel-update.d

export DEVENA_LIB_DIR FIRSTBOOT_DIR KERNEL_UPDATE_HOOK_DIR TOP

# Available devices
DEVICES := rpi asahi generic

# Utilities
INSTALL = install -D

ifneq ($(V),)
INSTALL = install -Dv
else ifneq ($(VERBOSE),)
INSTALL = install -Dv
endif

export INSTALL

.PHONY: $(DEVICES)

# This is required by all devices
generic-components = dracut
generic-files = devena-utils.bash
.PHONY: $(generic-components) $(generic-files)

install: install-generic $(generic-components) $(generic-files)
	@$(info)"Installing files for $(DEVICE) ..." $(clr)
	$(MAKE) -C $(DEVICE) $@
	@$(info)"Installation finished!" $(clr)

check:
	@if [ ! "$(DEVICE)" ] ; then \
		$(err)"Please specify a device." $(clr) ; \
		ERROR=1 ; \
	fi ; \
	if [ ! "$(TOP)" ] ; then \
		$(err)"Please run make at the project tree." $(clr) ; \
		ERROR=1 ; \
	fi ; \
	if [ ! "$(DESTDIR)" ] ; then \
		$(err)"Please specify DESTDIR while calling make." $(clr) ; \
		ERROR=1 ; \
	fi ; \
	if [ "$$ERROR" ] ; then \
		$(err)"Error(s) encountered - exiting." $(clr) ; \
		exit 1 ; \
	fi

install-generic: check
	@$(info)"Installing generic components ..."$(clr)

$(generic-components):
	@$(info)"Installing component $@ ..." $(clr)
	$(MAKE) -C $@ install

$(generic-files):
	@$(info)"Copying file $@" $(clr)
	@if [ -e "$(DEVICE)/$@" ] ; then \
		$(INSTALL) $(TOP)/$(DEVICE)/$@ $(DESTDIR)/$(DEVENA_LIB_DIR)/$@ ; \
	else \
		$(INSTALL) $(TOP)/$@ $(DESTDIR)/$(DEVENA_LIB_DIR)/$@ ; \
	fi

.PHONY: install
