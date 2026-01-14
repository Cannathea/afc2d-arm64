DEBUG = 0
FINALPACKAGE = 1

ARCHS = arm64 arm64e

THEOS_DEVICE_IP = 192.168.0.13

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET = iphone:16.5:15.0
else
export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
TARGET = iphone:14.5:11.0
endif

TOOL_NAME = extrainst_
$(TOOL_NAME)_FILES = extrainst.mm
$(TOOL_NAME)_FRAMEWORKS = Foundation
$(TOOL_NAME)_INSTALL_PATH = /DEBIAN
$(TOOL_NAME)_LIBRARIES = z
$(TOOL_NAME)_CODESIGN_FLAGS = -Sentitlements.xml
$(TOOL_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

TWEAK_NAME = afc2dService
$(TWEAK_NAME)_FILES = afc2dService.xm
$(TWEAK_NAME)_LIBRARIES = substrate
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tool.mk
include $(THEOS_MAKE_PATH)/tweak.mk
