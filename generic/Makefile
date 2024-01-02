#!/bin/make -f

COMPONENTS = first-boot.d

.PHONY: install-components install $(COMPONENTS)

install-components:
	@$(info)"Installing components for generic devices ..."

install: install-components $(COMPONENTS)
	@true

$(COMPONENTS):
	@$(info)"Installing component $@ ..."$(clr)
	$(MAKE) -C $@ install
