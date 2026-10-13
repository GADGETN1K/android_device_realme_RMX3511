#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Shipped with Android 11 (realme UI 2.0)
PRODUCT_SHIPPING_API_LEVEL := 30

# Virtual A/B — stock: ro.virtual_ab.enabled=true, ro.virtual_ab.compression.enabled=true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script \
    update_engine \
    update_engine_sideload \
    update_verifier

# Boot control
# Stock recovery uses AOSP android.hardware.boot@1.0-impl-1.2 + libbootloader_message,
# i.e. slot metadata in misc like AOSP, so the AOSP AIDL HAL replaces the stock
# vendor.sprd.hardware.boot@1.2-service.
PRODUCT_PACKAGES += \
    android.hardware.boot-service.default \
    android.hardware.boot-service.default_recovery

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := false

# fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot-service.example_recovery \
    fastbootd

# Display
TARGET_SCREEN_HEIGHT := 2408
TARGET_SCREEN_WIDTH := 1080

# Health
PRODUCT_PACKAGES += \
    android.hardware.health-service.example \
    android.hardware.health-service.example_recovery

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *
PRODUCT_PACKAGES += \
    FrameworksResOverlayRMX3511

# Rootdir — files are named after the board (ro.hardware / ro.product.board = ums9230_nico)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.ums9230_nico.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.ums9230_nico.rc \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.ums9230_nico.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.ums9230_nico.usb.rc \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.ram.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.ram.rc \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.storage.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.storage.rc \
    $(LOCAL_PATH)/rootdir/etc/fstab.ums9230_nico:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.ums9230_nico \
    $(LOCAL_PATH)/rootdir/etc/fstab.ums9230_nico:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.ums9230_nico

# Vendor is frozen at Android 12 (ro.vndk.version=31, VINTF target-level 6).
# TODO(build): make sure the VNDK v31 APEX ends up on system if the
# platform still needs it for S vendors.

# Inherit the proprietary files
$(call inherit-product, vendor/realme/RMX3511/RMX3511-vendor.mk)
