LOCAL_PATH := $(call my-dir)


include $(CLEAR_VARS)

ifeq ($(TARGET_ARCH),arm)

LOCAL_MODULE := python3.5m

LOCAL_C_INCLUDES := $(LOCAL_PATH)/include

LOCAL_STATIC_LIBRARIES := 

LOCAL_SHARED_LIBRARIES :=

LOCAL_LDLIBS := -L$(SYSROOT)/usr/lib -llog

LOCAL_SRC_FILES = lib/libpython3.5m.so 

include $(PREBUILT_SHARED_LIBRARY)


include $(CLEAR_VARS)

ifeq ($(TARGET_ARCH),arm)

LOCAL_MODULE := python3

LOCAL_C_INCLUDES := $(LOCAL_PATH)/include

LOCAL_STATIC_LIBRARIES := 

LOCAL_SHARED_LIBRARIES := python3.5m

LOCAL_LDLIBS := -L$(SYSROOT)/usr/lib -llog

LOCAL_SRC_FILES = lib/libpython3.so 

include $(PREBUILT_SHARED_LIBRARY)

endif # $(TARGET_ARCH),arm

endif # $(TARGET_ARCH),arm

