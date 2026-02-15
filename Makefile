ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AzuriteKey
AzuriteKey_FILES = Tweak.x
# Framework ini wajib untuk NSURLSession dan UIAlertController
AzuriteKey_FRAMEWORKS = UIKit Foundation
AzuriteKey_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
