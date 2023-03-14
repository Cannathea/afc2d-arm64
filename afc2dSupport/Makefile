DEBUG = 0
GO_EASY_ON_ME = 1
FINALPACKAGE = 1
ARCHS = arm64
TARGET = iphone:clang:latest:11.0

THEOS_DEVICE_IP = 192.168.0.15

include $(THEOS)/makefiles/common.mk

TOOL_NAME = afc2dSupport
$(TOOL_NAME)_FILES = afc2dSupport.mm
$(TOOL_NAME)_FRAMEWORKS = Foundation
$(TOOL_NAME)_LIBRARIES = z
$(TOOL_NAME)_CODESIGN_FLAGS = -Sent.plist
$(TOOL_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk
