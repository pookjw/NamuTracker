include $(THEOS)/makefiles/common.mk

SUBPROJECTS += modules/NamuTrackerApp
SUBPROJECTS += modules/NamuTrackerCCModule
SUBPROJECTS += modules/NamuTrackerHearthstoneHelper
SUBPROJECTS += modules/NamuTrackerSpringBoardHelper

include $(THEOS_MAKE_PATH)/aggregate.mk
