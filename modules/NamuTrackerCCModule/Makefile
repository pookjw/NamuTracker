TARGET := iphone:clang:latest
INSTALL_TARGET_PROCESSES = SpringBoard
export ARCHS=arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = NamuTrackerCCModule

$(BUNDLE_NAME)_BUNDLE_EXTENSION = bundle
$(BUNDLE_NAME)_CFLAGS +=  -fobjc-arc -Wno-unused-variable -Wno-unused-function -I$(THEOS_PROJECT_DIR)/headers
$(BUNDLE_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = ControlCenterUIKit AppSupport
$(BUNDLE_NAME)_LIBRARIES = rocketbootstrap
$(BUNDLE_NAME)_FILES = $(wildcard sources/*.m) $(wildcard $(THEOS_PROJECT_DIR)/common_sources/*.m)
$(BUNDLE_NAME)_INSTALL_PATH = /Library/ControlCenter/Bundles/

include $(THEOS_MAKE_PATH)/bundle.mk
