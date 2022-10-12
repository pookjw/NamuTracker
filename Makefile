include $(THEOS)/makefiles/common.mk

SUBPROJECTS += modules/NamuTrackerApp
SUBPROJECTS += modules/NamuTrackerCCModule
SUBPROJECTS += modules/NamuTrackerHearthstoneHelper
SUBPROJECTS += modules/NamuTrackerSpringBoardHelper

include $(THEOS_MAKE_PATH)/aggregate.mk

clean::
	rm -rf $(THEOS_PROJECT_DIR)/packages/* 
before-package::
	cp $(THEOS_PROJECT_DIR)/scripts/* $(THEOS_PROJECT_DIR)/.theos/_/DEBIAN/