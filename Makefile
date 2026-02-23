SHELL := /bin/bash

CXX := gcc
BUILD ?= debug
TARGET := build/app
SUBDIRS := source
BUILD_DIR := $(CURDIR)/build
INCLUDES := -I$(CURDIR)/include
LDFLAG := -lstdc++

ifeq ($(BUILD),debug)
CXXFLAGS := -std=c++23 -g -O0 -Wall -Wextra -Wpedantic $(INCLUDES)
MODETXT := DEBUG

else ifeq ($(BUILD),release)
CXXFLAGS := -std=c++23 -O2 -DNDEBUG $(INCLUDES)
MODETXT := RELEASE

else ifeq ($(BUILD),testing)
CXXFLAGS := -std=c++23 -O2 -DNDEBUG -Wall -Wextra -Wpedantic -Werror $(INCLUDES)
MODETXT := TESTING

else
$(error Unknown BUILD type)
endif

export CXX CXXFLAGS BUILD BUILD_DIR

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

.PHONY: all info subdirs link clean rebuild

all: info subdirs link

info:
	@echo "Build mode : $(MODETXT)"

subdirs:
	@for dir in $(SUBDIRS); do \
		$(call log,MAKE,$$dir); \
		$(MAKE) -C $$dir || exit 1; \
	done

link:
	$(Q)$(call log,LINK,$(TARGET))
	@mkdir -p $(BUILD_DIR)
	$(Q)$(CXX) $(OBJS) -o $(TARGET) $(LDFLAG)

clean:
	$(Q)$(call log,CLEAN,objects)
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
	@rm -rf $(BUILD_DIR)

rebuild: clean all
