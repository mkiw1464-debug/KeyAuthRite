# Ganti dengan nama projek kamu
TWEAK_NAME = AzuriteKey

# Senarai fail yang perlu di-build. Pastikan Tweak.x ada dalam folder projek.
AzuriteKey_FILES = Tweak.x

# Frameworks yang wajib ada untuk paparkan Alert (Login Box)
AzuriteKey_FRAMEWORKS = UIKit Foundation

# Tambahan Library untuk sokongan C++ dan Networking
AzuriteKey_LIBRARIES = z

# PENTING: Arahan kompiler untuk C++ dan skCrypt
AzuriteKey_CFLAGS = -fobjc-arc -std=c++11
AzuriteKey_CCFLAGS = -std=c++11 -fobjc-arc

# Arkitektur peranti (arm64 untuk iPhone lama, arm64e untuk iPhone baru/A12+)
ARCHS = arm64 arm64e

# Standard THEOS
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
