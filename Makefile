SHELL := /bin/bash

CXX := gcc
BUILD ?= debug
TARGET := build/app
SUBDIRS := source

BUILD_DIR := $(CURDIR)/build
export BUILD_DIR

INCLUDES := -Iinclude -Ilib -Isrc

ifeq ($(BUILD),debug)
CXXFLAGS := -std=c++23 -g -O0 -Wall -Wextra -lstdc++ $(INCLUDES)
MODETXT := DEBUG
else ifeq ($(BUILD),release)
CXXFLAGS := -std=c++23 -O3 -DNDEBUG -lstdc++ $(INCLUDES)
MODETXT := RELEASE
else
$(error Unknown BUILD type)
endif

export CXX CXXFLAGS BUILD

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
	$(Q)$(CXX) $(OBJS) -o $(TARGET) $(CXXFLAGS)

clean:
	$(Q)$(call log,CLEAN,objects)
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
	@rm -rf $(BUILD_DIR)

rebuild: clean all
