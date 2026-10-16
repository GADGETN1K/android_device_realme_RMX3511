#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/realme/RMX3511

# Shipped with Android 11 (realme UI 2.0)
PRODUCT_SHIPPING_API_LEVEL := 30

# ART userfaultfd GC. The build cannot infer it from our kernel version
# string (no -android12- suffix), but android12-5.4 has MREMAP_DONTUNMAP and
# userfaultfd minor faults backported, and ART falls back at runtime anyway.
PRODUCT_ENABLE_UFFD_GC := true

# Kernel modules: recovery load list next to the vendor ramdisk's
# modules.load (see BOOT_KERNEL_MODULES in BoardConfig.mk)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/modules.load.recovery:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/modules/modules.load.recovery \
    $(LOCAL_PATH)/modules.load.charger:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/modules.load.charger \
    $(LOCAL_PATH)/rootdir/bin/init.modules.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.modules.sh \
    $(LOCAL_PATH)/recovery/root/init.recovery.ums9230_nico.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.ums9230_nico.rc

# Touch firmware for recovery. The TDDI touch ICs keep their firmware in RAM
# and the driver loads it with request_firmware(); recovery has no /vendor,
# so ship the panel firmwares where the kernel looks directly (/lib/firmware).
RMX3511_TOUCH_FW := \
    Himax_firmware.bin \
    Himax_firmware_five.bin \
    Himax_firmware_signed.bin \
    ICNL9911C.bin \
    Nico_Huaqin_CID3501_D00_C81_20220429.bin \
    Nico_Huaqin_CID3502_D00_C01_20220429.bin \
    Normal_fts8006saa_Truly_BOE.bin \
    novatek_cs_fw.bin \
    novatek_tm_fw.bin \
    novatek_ts_fw.bin
PRODUCT_COPY_FILES += \
    $(foreach f,$(RMX3511_TOUCH_FW),vendor/realme/RMX3511/proprietary/vendor/firmware/$(f):$(TARGET_COPY_OUT_RECOVERY)/root/lib/firmware/$(f))

# Shims for S blobs
PRODUCT_PACKAGES += \
    libaeabi_shim_rmx3511 \
    libbase_shim \
    libbase_shim_rmx3511 \
    libtxml2v31 \
    libui_shim

# Virtual A/B — stock: ro.virtual_ab.enabled=true, ro.virtual_ab.compression.enabled=true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
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
    com.android.hardware.boot \
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

# vndservicemanager — no longer part of base_vendor.mk, but the S blobs
# register and look up services on /dev/vndbinder (codec2's priority
# manager, camera, CAS). Without it their getService() calls block forever,
# e.g. every c2.unisoc decoder hangs in start().
PRODUCT_PACKAGES += \
    vndservicemanager

# Power — Pixel libperfmgr (Lineage flavour) instead of the stock
# vendor.unisoc.hardware.power-service. configs/power/powerhint.json is
# written from the stock power_scene_config.xml / power_resource_file_info.xml:
# the same CPU floors, top-app uclamp and DDR "boost" vote, plus ADPF.
# power/ (libperfmgr-ext-rmx3511) serves Unisoc's IVendorPower as the IPower
# binder extension: hwcomposer, camera, codec2, RIL and audio reach the power
# HAL only through it (libpowerhal_cli), and their scenes map to the
# SCENE_<name> hints in powerhint.json.
PRODUCT_PACKAGES += \
    android.hardware.power-service.lineage-libperfmgr

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/power/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)/power \
    hardware/google/interfaces \
    hardware/google/pixel \
    hardware/lineage/interfaces/power-libperfmgr

$(call soong_config_set,power_libperfmgr,mode_extension_lib,//$(LOCAL_PATH)/power:libperfmgr-ext-rmx3511)

# Audio effects: the stock list (configs/audio/audio_effects.xml, from
# 13.F.54) plus ViPER4Android and Dolby Atmos (DAP, volume leveler). The
# stock audio HAL is 32-bit, so both need 32-bit effect libraries:
# libv4a_re is built for both ABIs, hardware/dolby ships both.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml

# ViPER4Android (vendor/viper: ViPERFX_RE built from source plus the app)
$(call inherit-product, vendor/viper/viper.mk)

# Dolby Atmos (crDroid's hardware/dolby: Motorola Dolby UI and DAX service)
$(call inherit-product, hardware/dolby/dolby.mk)

# Audio — generic modules from source; primary/bluetooth stay stock
PRODUCT_PACKAGES += \
    audio.r_submix.default \
    audio.usb.default

# Wi-Fi — stock legacy HAL (android.hardware.wifi@1.0-service), supplicant
# and hostapd from source (they bring their own init scripts and VINTF
# fragments). The stock wpa_supplicant.conf template stays in the blobs.
PRODUCT_PACKAGES += \
    hostapd \
    libwpa_client \
    wpa_supplicant

# NFC — NXP PN557 on /dev/nq-nci, OSS HAL from hardware/nxp/nfc/pn8x
PRODUCT_PACKAGES += \
    android.hardware.nfc@1.2-service \
    com.android.nfc_extras \
    Tag

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.uicc.xml \
    frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml

# Permissions — same feature set as stock vendor/etc/permissions
# (minus face unlock and reboot escrow)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.broadcastradio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.broadcastradio.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.manual_sensor.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.manual_sensor.xml \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.cdma.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_1.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.software.controls.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.controls.xml \
    frameworks/native/data/etc/android.software.cts.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.cts.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \
    frameworks/native/data/etc/android.software.managed_users.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.managed_users.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level-2021-03-01.xml \
    frameworks/native/data/etc/android.software.secure_lock_screen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.secure_lock_screen.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level-2021-03-01.xml \
    frameworks/native/data/etc/android.software.window_magnification.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.window_magnification.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *
PRODUCT_PACKAGES += \
    FrameworksResOverlayRMX3511 \
    SystemUIResOverlayRMX3511 \
    TelephonyResOverlayRMX3511 \
    TetheringResOverlayRMX3511 \
    WifiResOverlayRMX3511

# Rootdir — files are named after the board (ro.hardware / ro.product.board = ums9230_nico)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.ums9230_nico.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.ums9230_nico.rc \
    $(LOCAL_PATH)/rootdir/etc/init/init.rmx3511.hals.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.rmx3511.hals.rc \
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
