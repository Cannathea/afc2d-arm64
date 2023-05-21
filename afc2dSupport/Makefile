DEBUG = 0
FINALPACKAGE = 1
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TOOL_NAME = afc2dSupport
$(TOOL_NAME)_FILES = afc2dSupport.mm
$(TOOL_NAME)_FRAMEWORKS = Foundation
$(TOOL_NAME)_LIBRARIES = z
$(TOOL_NAME)_CODESIGN_FLAGS = -Sent.plist
$(TOOL_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tool.mk
