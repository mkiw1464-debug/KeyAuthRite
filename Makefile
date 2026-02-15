TWEAK_NAME = AzuriteKey
AzuriteKey_FILES = Tweak.xm
AzuriteKey_FRAMEWORKS = UIKit Foundation
AzuriteKey_LIBRARIES = z
AzuriteKey_CFLAGS = -fobjc-arc
AzuriteKey_CCFLAGS = -std=c++11 -fobjc-arc

ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
