DEBUG = 0
FINALPACKAGE = 1

INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS = arm64 arm64e

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET = iphone:16.2:15.0
else
TARGET = iphone:14.5:11.0
endif

THEOS_DEVICE_IP = 192.168.0.15

TWEAK_NAME = afc2dService afc2dSupport

afc2dService_FILES = afc2dService.xm
afc2dService_LIBRARIES = substrate
afc2dService_CFLAGS = -fobjc-arc

afc2dSupport_FILES = Tweak.xm
afc2dSupport_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

SUBPROJECTS += afc2dSupport

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
