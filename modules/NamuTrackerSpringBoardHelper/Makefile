TARGET := iphone:clang:latest
INSTALL_TARGET_PROCESSES = SpringBoard
export ARCHS=arm64 arm64e

TWEAK_NAME = NamuTrackerSpringBoardHelper

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-unused-function -I $(THEOS_PROJECT_DIR)/headers -I .
$(TWEAK_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(TWEAK_NAME)_FILES = $(wildcard *.m)

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

include $(THEOS_MAKE_PATH)/aggregate.mk
