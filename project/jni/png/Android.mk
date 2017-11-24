LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(notdir $(wildcard $(LOCAL_PATH)/*.c))

LOCAL_CFLAGS := -DHAVE_CONFIG_H
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include
# LOCAL_LDLIBS := z

LOCAL_MODULE := png

include $(BUILD_STATIC_LIBRARY)
