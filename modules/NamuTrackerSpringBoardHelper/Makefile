TARGET := iphone:clang:latest
INSTALL_TARGET_PROCESSES = SpringBoard
export ARCHS = arm64 arm64e

TWEAK_NAME = NamuTrackerSpringBoardHelper

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -fobjc-weak -Wno-unused-variable -Wno-unused-function -I$(addprefix -I,$(shell find . -type d)) -I$(addprefix -I,$(shell find $(THEOS_PROJECT_DIR)/common -type d))
$(TWEAK_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(TWEAK_NAME)_FILES = $(shell find . -type f -name  "*.m") $(shell find $(THEOS_PROJECT_DIR)/common -type f -name  "*.m")

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
