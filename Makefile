export THEOS_DEVICE_IP = 127.0.0.1
TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AzuriteKey
AzuriteKey_FILES = Tweak.x
AzuriteKey_FRAMEWORKS = UIKit Foundation Security
AzuriteKey_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
