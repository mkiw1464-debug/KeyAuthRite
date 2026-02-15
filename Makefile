TWEAK_NAME = AzuriteKey

# Pastikan nama fail di bawah sama dengan yang kamu rename tadi (.xm)
AzuriteKey_FILES = Tweak.xm
AzuriteKey_FRAMEWORKS = UIKit Foundation
AzuriteKey_LIBRARIES = z

# CFLAGS untuk Objective-C, CCFLAGS untuk C++
AzuriteKey_CFLAGS = -fobjc-arc
AzuriteKey_CCFLAGS = -std=c++11 -fobjc-arc

ARCHS = arm64 arm64e
# Set target ke iOS 14 ke atas untuk sokongan arm64e yang lebih baik
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
