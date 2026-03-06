SHELL := /bin/bash

CC := gcc
BUILD ?= debug

TARGET := build/uuc
SUBDIRS := source

BUILD_DIR := $(CURDIR)/build
TOOLS_DIR := $(CURDIR)/tools

INCLUDES := -I$(CURDIR)/include

PCH_HEADER := $(CURDIR)/include/pch.h
PCH_FILE := $(TOOLS_DIR)/pch.h.gch

LDFLAGS :=

ifeq ($(BUILD),debug)
CFLAGS := -std=gnu11 -g -O0 -Wall -Wextra -Wpedantic -Wstrict-prototypes $(INCLUDES)
MODETXT := DEBUG

else ifeq ($(BUILD),debugres)
CFLAGS := -std=gnu11 -O0 -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wundef -Wformat -Wsign-conversion -Wcast-align -Wstrict-prototypes $(INCLUDES)
MODETXT := DEBUGRES

else ifeq ($(BUILD),release)
CFLAGS := -std=gnu11 -O2 -DNDEBUG $(INCLUDES)
MODETXT := RELEASE

else ifeq ($(BUILD),restriction)
CFLAGS := -std=gnu11 -O0 -Wall -Wextra -Wpedantic -Werror -Wstrict-prototypes $(INCLUDES)
MODETXT := RESTRICTION

else
$(error Unknown BUILD type)
endif

# cek apakah pch.h ada
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
else
Q := @
endif

define log
printf "  %-7s %s\n" "$(1)" "$(2)"
endef

OBJS = $(shell find $(BUILD_DIR) -name '*.o' 2>/dev/null)

.PHONY: all info subdirs link clean rebuild pch

all: info subdirs link

info:
	@echo "Build mode : $(MODETXT)"
	@if [ "$(HAS_PCH)" = "1" ]; then \
		if [ -f "$(PCH_FILE)" ]; then \
			echo "PCH        : available"; \
		else \
			echo "PCH        : header exists (not compiled)"; \
		fi \
	else \
		echo "PCH        : none"; \
	fi

pch:
ifeq ($(HAS_PCH),1)
	$(Q)$(call log,PCH,$(PCH_HEADER))
	@mkdir -p $(TOOLS_DIR)
	$(Q)$(CC) $(CFLAGS) -x c-header $(PCH_HEADER) -o $(PCH_FILE)
else
	@echo "No pch.h found"
endif

subdirs:
	@for dir in $(SUBDIRS); do \
		$(call log,MAKE,$$dir); \
		$(MAKE) -C $$dir || exit 1; \
	done

link:
	$(Q)$(call log,LINK,$(TARGET))
	@mkdir -p $(BUILD_DIR)
	$(Q)$(CC) $(OBJS) -o $(TARGET) $(LDFLAGS)

clean:
	$(Q)$(call log,CLEAN,objects)
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
	@rm -rf $(BUILD_DIR)

rebuild: clean all
