DRACUT_COMPONENTS = \
		    modules.d

.PHONY: install-components install $(DRACUT_COMPONENTS)

install-components:
	@$(info)"Installing dracut components ..." $(clr)

install: install-components $(DRACUT_COMPONENTS)
	@true

$(DRACUT_COMPONENTS):
	make -C $@ install
