TARGET := iphone:clang:latest
INSTALL_TARGET_PROCESSES = hearthstone
export ARCHS=arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NamuTrackerHSHelper

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-unused-function -I$(THEOS_PROJECT_DIR)/headers
$(TWEAK_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = AppSupport
$(TWEAK_NAME)_LIBRARIES = rocketbootstrap
$(TWEAK_NAME)_FILES = $(wildcard *.x) $(wildcard *.m)

include $(THEOS_MAKE_PATH)/tweak.mk
