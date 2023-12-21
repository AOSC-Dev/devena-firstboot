# Devena - AOSC OS Device Support Task Force
# This Makefile is the recipe to install this dracht module to the target
# system.

MODULE_NAME = devena-firstboot
MODULE_PRIORITY = 99

# Dracut module path
DRACUT_MODULE_PATH ?= /usr/lib/dracut/modules.d

# Systemd unit file
SYSTEMD_SERVICE_FILE = devena-firstboot.service

# The main script/binary executable
MAIN_BIN_FILE = devena-firstboot.bash

# Additional files
ADDITIONAL_FILES = 

# Additional executables
ADDITIONAL_EXECUTABLES = 

.PHONY: install install-component $(SYSTEMD_SERVICE_FILE) $(MAIN_BIN_FILE) $(ADDITIONAL_FILES) $(ADDITIONAL_EXECUTABLES)

install: install-component $(SYSTEMD_SERVICE_FILE) $(MAIN_BIN_FILE) $(ADDITIONAL_FILES) $(ADDITIONAL_EXECUTABLES)
	@$(info)"Installing module setup script ..." $(clr)
	@$(INSTALL) -Dm755 "$(CURDIR)/module-setup.sh" "$(DESTDIR)/$(DRACUT_MODULE_PATH)/$(MODULE_PRIORITY)$(MODULE_NAME)/module-setup.sh"

install-component:
	@$(info)"Installing files of module $(MODULE_NAME) ..." $(clr)

$(SYSTEMD_SERVICE_FILE):
	@$(INSTALL) -Dm644 "$(CURDIR)/$@" "$(DESTDIR)/$(DRACUT_MODULE_PATH)/$(MODULE_PRIORITY)$(MODULE_NAME)/$@"

$(MAIN_BIN_FILE):
	@$(INSTALL) -Dm755 "$(CURDIR)/$@" "$(DESTDIR)/$(DRACUT_MODULE_PATH)/$(MODULE_PRIORITY)$(MODULE_NAME)/$@"

$(ADDITIONAL_FILES):
	@$(INSTALL) -Dm644 "$(CURDIR)/$@" "$(DESTDIR)/$(DRACUT_MODULE_PATH)/$(MODULE_PRIORITY)$(MODULE_NAME)/$@"

$(ADDITIONAL_EXECUTABLES):
	@$(INSTALL) -Dm755 "$(CURDIR)/$@" "$(DESTDIR)/$(DRACUT_MODULE_PATH)/$(MODULE_PRIORITY)$(MODULE_NAME)/$@"

