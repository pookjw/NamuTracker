TARGET := iphone:clang:latest
INSTALL_TARGET_PROCESSES = NamuTrackerApp
export ARCHS = arm64 arm64e

APPLICATION_NAME = NamuTrackerApp

$(APPLICATION_NAME)_CFLAGS = -fobjc-arc -fobjc-weak -Wno-unused-variable -Wno-unused-function -DSYSTEMLAND_APP\=1 -I$(addprefix -I,$(shell find . -type d)) -I$(addprefix -I,$(shell find $(THEOS_PROJECT_DIR)/common -type d))
$(APPLICATION_NAME)_FRAMEWORKS = UIKit CoreGraphics StoreKit CoreData
$(APPLICATION_NAME)_PRIVATE_FRAMEWORKS = AppSupport
$(APPLICATION_NAME)_LIBRARIES = rocketbootstrap

$(APPLICATION_NAME)_FILES = $(shell find . -type f -name  "*.m") $(shell find $(THEOS_PROJECT_DIR)/common -type f -name  "*.m")

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
