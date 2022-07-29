.DEFAULT_GOAL = get-sources
.SECONDEXPANSION:

DIST ?= fc32
VERSION := $(shell cat version)

FEDORA_SOURCES := https://src.fedoraproject.org/rpms/alsa-sof-firmware/raw/f$(subst fc,,$(DIST))/f/sources
SRC_FILE := sof-bin-v$(VERSION).tar.gz
SRC_ADDON_FILE := sof-tplg-v$(VERSION)a.tar.gz

BUILDER_DIR ?= ../..
SRC_DIR ?= qubes-src

SRC_URLS := \
			https://github.com/thesofproject/sof-bin/releases/download/v$(VERSION)/$(SRC_FILE) \
			https://github.com/thesofproject/sof-bin/releases/download/v$(VERSION)a/$(SRC_ADDON_FILE)
UNTRUSTED_SUFF := .UNTRUSTED

SHELL := bash

.PHONY: get-sources verify-sources clean clean-sources

ifeq ($(FETCH_CMD),)
$(error "You can not run this Makefile without having FETCH_CMD defined")
endif

%: %.sha512
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF) -- $(filter %/$@,$(SRC_URLS))
	@sha512sum --status -c <(printf "$$(cat $<)  -\n") <$@$(UNTRUSTED_SUFF) || \
		{ echo "Wrong SHA512 checksum on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@mv $@$(UNTRUSTED_SUFF) $@

get-sources: $(SRC_FILE) $(SRC_ADDON_FILE)
	@true

verify-sources:
	@true

clean:
	@true

clean-sources:
	rm -f $(SRC_FILE) $(SRC_ADDON_FILE) *$(UNTRUSTED_SUFF)

# This target is generating content locally from upstream project
# # 'sources' file. Sanitization is done but it is encouraged to perform
# # update of component in non-sensitive environnements to prevent
# # any possible local destructions due to shell rendering
# .PHONY: update-sources
update-sources:
	@$(BUILDER_DIR)/$(SRC_DIR)/builder-rpm/scripts/generate-hashes-from-sources $(FEDORA_SOURCES)
