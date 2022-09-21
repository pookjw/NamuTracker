TARGET := iphone:clang:latest
INSTALL_TARGET_PROCESSES = NamuTrackerApp
export ARCHS=arm64 arm64e

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = NamuTrackerApp

$(APPLICATION_NAME)_CFLAGS = -fobjc-arc -Wno-unused-variable -I$(THEOS_PROJECT_DIR)/headers
$(APPLICATION_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(APPLICATION_NAME)_PRIVATE_FRAMEWORKS = AppSupport
$(APPLICATION_NAME)_LIBRARIES = rocketbootstrap

$(APPLICATION_NAME)_FILES = $(wildcard *.m)

include $(THEOS_MAKE_PATH)/application.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
