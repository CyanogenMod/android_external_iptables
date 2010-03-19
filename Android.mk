ifneq ($(TARGET_SIMULATOR),true)
  BUILD_IPTABLES := 1
endif
ifeq ($(BUILD_IPTABLES),1)

LOCAL_PATH:= $(call my-dir)

#
# Build libraries
#

# libiptc

include $(CLEAR_VARS)

LOCAL_C_INCLUDES:= \
	$(KERNEL_HEADERS) \
	$(LOCAL_PATH)/include/

LOCAL_CFLAGS:=-DNO_SHARED_LIBS

LOCAL_SRC_FILES:= \
	libiptc/libip4tc.c

LOCAL_MODULE_TAGS:=
LOCAL_MODULE:=libiptc

include $(BUILD_STATIC_LIBRARY)

# libext

include $(CLEAR_VARS)

LOCAL_MODULE_TAGS:=
LOCAL_MODULE:=libext

# LOCAL_MODULE_CLASS must be defined before calling $(local-intermediates-dir)
#
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
intermediates := $(call local-intermediates-dir)

LOCAL_C_INCLUDES:= \
	$(LOCAL_PATH)/include/ \
	$(KERNEL_HEADERS) \
	$(intermediates)/extensions/

LOCAL_CFLAGS:=-DNO_SHARED_LIBS
LOCAL_CFLAGS+=-DXTABLES_INTERNAL
LOCAL_CFLAGS+=-DIPTABLES_VERSION=\"1.4.7\"

PF_EXT_SLIB:=ah addrtype ecn icmp realm ttl unclean DNAT LOG #DSCP ECN
PF_EXT_SLIB+=MASQUERADE MIRROR NETMAP REDIRECT REJECT #MARK
PF_EXT_SLIB+=SAME SNAT ULOG # TOS TCPMSS TTL

XT_SLIB:=comment connmark conntrack dscp esp hashlimit helper iprange length limit mac multiport owner physdev pkttype policy standard state tcp udp tcpmss tos CLASSIFY CONNMARK NFQUEUE NOTRACK

EXT_FUNC+=$(foreach T,$(PF_EXT_SLIB),ipt_$(T))
EXT_FUNC+=$(foreach T,$(XT_SLIB),xt_$(T))

# generated headers

GEN_INITEXT:= $(intermediates)/extensions/gen_initext.c
$(GEN_INITEXT): PRIVATE_PATH := $(LOCAL_PATH)
$(GEN_INITEXT): PRIVATE_CUSTOM_TOOL = $(PRIVATE_PATH)/extensions/create_initext "$(EXT_FUNC)" > $@
$(GEN_INITEXT): PRIVATE_MODULE := $(LOCAL_MODULE)
$(GEN_INITEXT):
	$(transform-generated-source)

$(intermediates)/extensions/initext.o : $(GEN_INITEXT)

LOCAL_GENERATED_SOURCES:= $(GEN_INITEXT)

LOCAL_SRC_FILES:= \
	$(foreach T,$(PF_EXT_SLIB),extensions/libipt_$(T).c) \
	$(foreach T,$(XT_SLIB),extensions/libxt_$(T).c) \
	extensions/initext.c

LOCAL_STATIC_LIBRARIES := \
	libc

include $(BUILD_STATIC_LIBRARY)

#
# Build iptables
#

include $(CLEAR_VARS)

LOCAL_C_INCLUDES:= \
	$(LOCAL_PATH)/include/ \
	$(KERNEL_HEADERS)

LOCAL_CFLAGS:=-DNO_SHARED_LIBS
LOCAL_CFLAGS+=-DIPTABLES_VERSION=\"1.4.7\" -DXTABLES_LIBDIR=\"/system/lib\" -DXTABLES_INTERNAL

LOCAL_SRC_FILES:= \
	iptables.c \
	xshared.c \
	xtables.c \
	iptables-standalone.c 

LOCAL_MODULE_TAGS:=
LOCAL_MODULE:=iptables

LOCAL_STATIC_LIBRARIES := \
	libiptc \
	libext

include $(BUILD_EXECUTABLE)

endif
