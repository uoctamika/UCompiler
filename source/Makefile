SHELL := /bin/bash

OUT := $(BUILD_DIR)

SRC := $(wildcard *.c)
OBJ := $(patsubst %.c,$(OUT)/%.o,$(SRC))
DEP := $(OBJ:.o=.d)

V ?= 0
ifeq ($(V),1)
Q :=
USE_ABS := 1
else
Q := @
USE_ABS :=
endif

logpath = $(if $(USE_ABS),$(CURDIR)/$<,$<)

define log
printf "  %-7s %s\n" "$(1)" "$(2)"
endef

ifneq ("$(wildcard $(PCH_FILE))","")
PCH_DEP := $(PCH_FILE)
else
PCH_DEP :=
endif

.PHONY: all clear

all: $(OBJ)

$(OUT)/%.o: %.c $(PCH_DEP)
	@mkdir -p $(OUT)
	$(Q)$(call log,CC,$(call logpath))
	$(Q)$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

clear:
	@rm -f $(OUT)/*.o $(OUT)/*.d

-include $(DEP)
