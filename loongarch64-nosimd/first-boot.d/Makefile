include files.mk
install:
	@echo "Installing first boot scripts ..." ; \
	for i in $(files-firstboot-asahi) ; do \
		$(INSTALL) -Dm644 $(TOP)/asahi/first-boot.d/$$i $(DESTDIR)/$(FIRSTBOOT_DIR)/$$i ; \
	done ; \
	for i in $(files-firstboot-general) ; do \
		$(INSTALL) -Dm644 $(TOP)/first-boot.d/$$i $(DESTDIR)/$(FIRSTBOOT_DIR)/$$i ; \
	done ; \

.PHONY: install
