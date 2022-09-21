include $(THEOS)/makefiles/common.mk

SUBPROJECTS += submodules/NamuTrackerApp
SUBPROJECTS += submodules/NamuTrackerHelper
SUBPROJECTS += submodules/NamuTrackerCCModule

include $(THEOS_MAKE_PATH)/aggregate.mk
