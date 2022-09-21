TARGET := iphone:clang:latest:14.8
INSTALL_TARGET_PROCESSES = NamuTracker

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = NamuTracker

NamuTracker_FILES = $(wildcard *.m)
NamuTracker_FRAMEWORKS = UIKit CoreGraphics
NamuTracker_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk
