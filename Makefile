TARGET =: clang::7.0
ARCHS = arm64
DEBUG = 0
GO_EASY_ON_ME = 1

THEOS_PACKAGE_DIR_NAME = debs
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

TOOL_NAME = postrm extrainst_

postrm_FILES = postrm.mm
postrm_FRAMEWORKS = Foundation
postrm_INSTALL_PATH = /DEBIAN
postrm_CODESIGN_FLAGS = -Sentitlements.xml

extrainst__FILES = extrainst.mm
extrainst__FRAMEWORKS = Foundation
extrainst__INSTALL_PATH = /DEBIAN
extrainst__LIBRARIES = z
extrainst__CODESIGN_FLAGS = -Sentitlements.xml

include $(THEOS_MAKE_PATH)/tool.mk

TWEAK_NAME = afc2dService
afc2dService_FILES = afc2dService.xm
afc2dService_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk