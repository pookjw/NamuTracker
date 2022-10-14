include $(THEOS)/makefiles/common.mk

SUBPROJECTS += modules/NamuTrackerApp
SUBPROJECTS += modules/NamuTrackerCCModule
SUBPROJECTS += modules/NamuTrackerHearthstoneHelper
SUBPROJECTS += modules/NamuTrackerSpringBoardHelper

include $(THEOS_MAKE_PATH)/aggregate.mk

clean::
	rm -rf $(THEOS_PROJECT_DIR)/packages/* 
before-package::
	cp $(THEOS_PROJECT_DIR)/post_scripts/* $(THEOS_PROJECT_DIR)/.theos/_/DEBIAN/
	cd $(THEOS_PROJECT_DIR) && $(THEOS_PROJECT_DIR)/scripts/build_app_assets.sh
	cd $(THEOS_PROJECT_DIR) && $(THEOS_PROJECT_DIR)/scripts/build_cd_moms.sh