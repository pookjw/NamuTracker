TARGET := iphone:clang:latest
INSTALL_TARGET_PROCESSES = hearthstone
export ARCHS=arm64 arm64e

TWEAK_NAME = NamuTrackerHearthstoneHelper

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-unused-function -I $(THEOS_PROJECT_DIR)/headers -I . -I Service/HSLogService
$(TWEAK_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = AppSupport
$(TWEAK_NAME)_LIBRARIES = rocketbootstrap
$(TWEAK_NAME)_FILES = $(wildcard *.m) $(wildcard Service/HSLogService/*.m)

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
