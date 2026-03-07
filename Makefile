SHELL := /bin/bash

CC := gcc
BUILD ?= debug

TARGET := build/uuc
SUBDIRS := source

BUILD_DIR := $(CURDIR)/build
INCLUDES := -I$(CURDIR)/include

PCH_HEADER := $(CURDIR)/include/ucc/tools/pch.h
PCH_HEADER_REL := include/ucc/tools/pch.h
PCH_FILE := $(BUILD_DIR)/pch.h.gch

LDFLAGS :=

ifeq ($(BUILD),debug)
CFLAGS := -std=gnu11 -g -O0 -Wall -Wextra -Wpedantic -Wstrict-prototypes -DPCH_COMPILED $(INCLUDES)
MODETXT := DEBUG
else ifeq ($(BUILD),debugres)
CFLAGS := -std=gnu11 -O0 -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wundef -Wformat -Wsign-conversion -Wcast-align -Wstrict-prototypes -DPCH_COMPILED $(INCLUDES)
MODETXT := DEBUGRES
else ifeq ($(BUILD),release)
CFLAGS := -std=gnu11 -O2 -DNDEBUG -DPCH_CONPILED $(INCLUDES)
MODETXT := RELEASE
else ifeq ($(BUILD),restriction)
CFLAGS := -std=gnu11 -O0 -Wall -Wextra -Wpedantic -Werror -Wstrict-prototypes $(INCLUDES)
MODETXT := RESTRICTION
else ifeq ($(BUILD),pch)
CFLAGS := -std=gnu11 -O0 -g -DPCH_COMPILED $(INCLUDES)
MODETXT := PCH

else
$(error Unknown BUILD type)
endif

ifneq ("$(wildcard $(PCH_HEADER))","")
HAS_PCH := 1
else
HAS_PCH := 0
endif

export CC CFLAGS BUILD BUILD_DIR PCH_FILE PCH_HEADER HAS_PCH

MAKEFLAGS += --no-print-directory

V ?= 0
ifeq ($(V),1)
Q :=
USE_ABS := 1
else
Q := @
USE_ABS :=
endif

logpath = $(if $(USE_ABS),$(1),$(2))

define log
printf "  %-7s %s\n" "$(1)" "$(2)"
endef

OBJS = $(shell find $(BUILD_DIR) -name '*.o' 2>/dev/null)

.PHONY: all info subdirs link clear rebuild pch

all: info pch subdirs link

info:
	@echo "Build mode : $(MODETXT)"
	@if [ "$(HAS_PCH)" = "1" ]; then \
		if [ -f "$(PCH_FILE)" ]; then \
			echo "PCH        : compiled"; \
		else \
			echo "PCH        : header exists (not compiled)"; \
		fi \
	else \
		echo "PCH        : none"; \
	fi

pch:
ifeq ($(HAS_PCH),1)
	$(Q)$(call log,PCH,$(call logpath,$(PCH_HEADER),$(PCH_HEADER_REL)))
	@mkdir -p $(BUILD_DIR)
	$(Q)$(CC) $(CFLAGS) -x c-header $(PCH_HEADER) -o $(PCH_FILE)
else
	@echo "No pch.h found"
endif

subdirs:
	@for dir in $(SUBDIRS); do \
		$(call log,MAKE,$$dir); \
		$(MAKE) -C $$dir V=$(V) || exit 1; \
	done

link:
	$(Q)$(call log,LINK,$(TARGET))
	@mkdir -p $(BUILD_DIR)
	$(Q)$(CC) $(OBJS) -o $(TARGET) $(LDFLAGS)

clear:
	$(Q)$(call log,CLEAR,build)
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clear V=$(V); \
	done
	@rm -rf $(BUILD_DIR)

rebuild: clear all
