kernel-update-hooks = \
	01-rpi-update-kernel

install:
	@$(info)"Installing kernel update hooks ..." $(clr)
	@for i in $(kernel-update-hooks) ; do \
		$(INSTALL) -Dm644 $(CURDIR)/$$i $(DESTDIR)/$(KERNEL_UPDATE_HOOK_DIR)/$$i ; \
	done
.PHONY: install
