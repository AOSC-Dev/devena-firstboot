DRACUT_MODULES = \
		 99devena-firstboot

.PHONY: install-modules install $(DRACUT_MODULES)

install-components:
	@$(info)"Installing dracut modules ..." $(clr)

install: install-modules $(DRACUT_MODULES)
	@true

$(DRACUT_MODULES):
	@$(info)"Installing module $@ ..." $(clr)
	make -C $@ install
