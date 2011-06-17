LOCAL_PATH:= $(call my-dir)

#----------------------------------------------------------------
# libxtables

include $(CLEAR_VARS)

LOCAL_C_INCLUDES:= \
	$(LOCAL_PATH)/../include/ \
	$(LOCAL_PATH)/../iptables/ \
	$(LOCAL_PATH)/../ \
	$(KERNEL_HEADERS)

LOCAL_CFLAGS:=-DNO_SHARED_LIBS=1
LOCAL_CFLAGS+=-DXTABLES_INTERNAL=1
LOCAL_CFLAGS+=-DXTABLES_LIBDIR=\"xtables_libdir_not_used\"
# Accommodate arm-eabi-4.4.3 tools that don't set __ANDROID__
LOCAL_CFLAGS+=-D__ANDROID__

LOCAL_LDFLAGS:=-version-info 7:0:0

LOCAL_SRC_FILES:= \
	xtables.c \
	xtoptions.c

LOCAL_MODULE:=libxtables

include $(BUILD_STATIC_LIBRARY)
