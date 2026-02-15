ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AzuriteKey
AzuriteKey_FILES = Tweak.x
# Tambah UIKit dan Foundation di bawah
AzuriteKey_FRAMEWORKS = UIKit Foundation
AzuriteKey_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
