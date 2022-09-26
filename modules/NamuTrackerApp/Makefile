TARGET := iphone:clang:latest
INSTALL_TARGET_PROCESSES = NamuTrackerApp
export ARCHS=arm64 arm64e

APPLICATION_NAME = NamuTrackerApp

$(APPLICATION_NAME)_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-unused-function -I $(THEOS_PROJECT_DIR)/common/headers -I $(addprefix -I,$(shell find . -type d))
$(APPLICATION_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(APPLICATION_NAME)_PRIVATE_FRAMEWORKS = AppSupport
$(APPLICATION_NAME)_LIBRARIES = rocketbootstrap

$(APPLICATION_NAME)_FILES = $(shell find . -type f -name  "*.m")

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
