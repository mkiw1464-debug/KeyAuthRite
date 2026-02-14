ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AzuriteKey
AzuriteKey_FILES = Tweak.x
AzuriteKey_FRAMEWORKS = UIKit Foundation Security
AzuriteKey_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
