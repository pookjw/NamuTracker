TARGET := iphone:clang:latest
INSTALL_TARGET_PROCESSES = SpringBoard
export ARCHS=arm64 arm64e

BUNDLE_NAME = NamuTrackerCCModule

$(BUNDLE_NAME)_BUNDLE_EXTENSION = bundle
$(BUNDLE_NAME)_CFLAGS += -fobjc-arc -fobjc-weak -Wno-unused-variable -Wno-unused-function -I$(THEOS_PROJECT_DIR)/common/headers -I$(addprefix -I,$(shell find . -type d))
$(BUNDLE_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = ControlCenterUIKit AppSupport
$(BUNDLE_NAME)_LIBRARIES = rocketbootstrap
$(BUNDLE_NAME)_FILES = $(shell find . -type f -name  "*.m")
$(BUNDLE_NAME)_INSTALL_PATH = /Library/ControlCenter/Bundles/

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
