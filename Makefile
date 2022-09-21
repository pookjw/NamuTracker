include $(THEOS)/makefiles/common.mk

SUBPROJECTS += modules/NamuTrackerApp
SUBPROJECTS += modules/NamuTrackerHelper
SUBPROJECTS += modules/NamuTrackerCCModule

include $(THEOS_MAKE_PATH)/aggregate.mk
