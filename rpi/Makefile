#!/bin/make -f

COMPONENTS = first-boot.d kernel-update.d

.PHONY: install-components install $(COMPONENTS)

install-components:
	@$(info)"Installing components for rpi ..."

install: install-components $(COMPONENTS)
	@$(info)"Installing libraries ..."$(clr) ; \
	$(INSTALL) $(CURDIR)/lib-rpi.bash $(DESTDIR)/$(DEVENA_LIB_DIR)/lib-rpi.bash

$(COMPONENTS):
	@$(info)"Installing component $@ ..."$(clr)
	$(MAKE) -C $@ install
