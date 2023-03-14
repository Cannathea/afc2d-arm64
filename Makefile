DEBUG = 0
GO_EASY_ON_ME = 1
FINALPACKAGE = 1
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:11.0

THEOS_DEVICE_IP = 192.168.0.15

TWEAK_NAME = afc2dService afc2dSupport

afc2dService_FILES = afc2dService.xm
afc2dService_LIBRARIES = substrate
afc2dService_CFLAGS = -fobjc-arc

afc2dSupport_FILES = Tweak.xm
afc2dSupport_CFLAGS = -fobjc-arc

SUBPROJECTS += afc2dSupport

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	ldid -s $(THEOS_STAGING_DIR)/usr/bin/afc2dSupport
	sudo chown -R root:wheel $(THEOS_STAGING_DIR)
	sudo chmod -R 755 $(THEOS_STAGING_DIR)
	sudo chmod 6755 $(THEOS_STAGING_DIR)/usr/bin/afc2dSupport
	sudo chmod 666 $(THEOS_STAGING_DIR)/DEBIAN/control

after-package::
	make clean
	sudo mv .theos/_ $(THEOS_PACKAGE_NAME)_$(THEOS_PACKAGE_BASE_VERSION)_iphoneos-arm
	zip -r .theos/$(THEOS_PACKAGE_NAME)_$(THEOS_PACKAGE_BASE_VERSION)_iphoneos-arm.zip $(THEOS_PACKAGE_NAME)_$(THEOS_PACKAGE_BASE_VERSION)_iphoneos-arm
	mv .theos/$(THEOS_PACKAGE_NAME)_$(THEOS_PACKAGE_BASE_VERSION)_iphoneos-arm.zip ./
	sudo rm -rf $(THEOS_PACKAGE_NAME)_$(THEOS_PACKAGE_BASE_VERSION)_iphoneos-arm

after-install::
	install.exec "killall -9 backboardd"
