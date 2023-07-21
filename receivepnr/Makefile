THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222
ARCHS = arm64
TARGET := iphone:clang:10.3

include $(THEOS)/makefiles/common.mk

TOOL_NAME = ReceivePNR

ReceivePNR_FILES = main.m
ReceivePNR_CFLAGS = -fobjc-arc
ReceivePNR_CODESIGN_FLAGS = -Sentitlements.plist
ReceivePNR_INSTALL_PATH = /usr/local/bin
ReceivePNR_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/tool.mk
