#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/realme/RMX3511

# Values below come from the stock RMX3511_13.F.54 (Global) PAC:
# ums9230_nico.xml (partition table), boot/vendor_boot headers, vbmeta.
# See docs/partitions.md. Lines still marked TODO(dump) need super/vendor.

# Architecture (Unisoc T616: 2x Cortex-A75 + 6x Cortex-A55)
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a75

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Platform
TARGET_BOARD_PLATFORM := ums9230
# PAC scheme / kernel diffconfig / fstab suffix are all "ums9230_nico";
# stock ro.product.device is RE87BAL1.
TARGET_BOOTLOADER_BOARD_NAME := ums9230_nico
TARGET_NO_BOOTLOADER := true

# OTA
TARGET_OTA_ASSERT_DEVICE := RMX3511,RE87BAL1

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    product \
    system \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot \
    vendor_dlkm

# Boot image (stock: boot header v4, GKI boot.img with empty cmdline;
# vendor_boot v4, page 4096, base 0)
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_RAMDISK_OFFSET := 0x05400000
BOARD_DTB_OFFSET := 0x01f00000
BOARD_KERNEL_IMAGE_NAME := Image

BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)

# Stock vendor_boot cmdline
BOARD_KERNEL_CMDLINE := console=ttyS1,115200n8 buildvariant=user

BOARD_RAMDISK_USE_LZ4 := true

# DTB / DTBO — prebuilt from stock for now (see docs/kernel.md):
#  - vendor_boot DTB is a 1-entry DT table (mkdtimg format) with ums9230.dtb
#  - stock dtbo has 21 overlays; the published kernel source does not build
#    the nico overlays for qogirl6, so it can't reproduce this dtbo yet
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilts/dtb
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilts/dtbo.img

# Kernel — built from source. Stock runs the Google GKI android12-5.4 kernel
# (5.4.210-android12-9); realme's source is the same KMI branch at 5.4.254.
TARGET_KERNEL_SOURCE := kernel/realme/RMX3511
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    vendor/ums9230.config \
    vendor/RMX3511.config
TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_NO_GCC := true

# Out-of-tree modules in kernel_modules/kernel5.4 (gpu, wcn, input, nfc, npu)
# and kernel_modules/common/camera.
# TODO(kernel): wire them up via TARGET_KERNEL_EXT_MODULES.

# Kernel modules load lists — copied from stock vendor_boot
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(DEVICE_PATH)/modules.load.vendor_boot))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(DEVICE_PATH)/modules.load.recovery))
# vendor_dlkm list — copied from stock, loaded by init.ums9230_nico.rc
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(DEVICE_PATH)/modules.load 2>/dev/null))

# Partitions (sizes from ums9230_nico.xml, units MiB there)
BOARD_FLASH_BLOCK_SIZE := 262144
# 64M
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
# 100M
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 104857600
# 8M
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
# 8000M
BOARD_SUPER_PARTITION_SIZE := 8388608000

# Virtual A/B (stock ro.virtual_ab.enabled=true): one group,
# max = super - 4MiB metadata overhead.
BOARD_SUPER_PARTITION_GROUPS := realme_dynamic_partitions
BOARD_REALME_DYNAMIC_PARTITIONS_SIZE := 8384413696
BOARD_REALME_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    product \
    system \
    system_ext \
    vendor \
    vendor_dlkm

# Stock dynamic partitions are erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

BOARD_USES_VENDOR_DLKMIMAGE := true

TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Recovery (lives in vendor_boot on this device)
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.ums9230_nico
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
TARGET_NO_RECOVERY := true

# Screen
TARGET_SCREEN_DENSITY := 480

# Verified Boot
# Stock vbmeta chains boot, vendor_boot, dtbo, vbmeta_{system,vendor,system_ext,product}
# and the modem images (l_modem, l_ldsp, l_gdsp, pm_sys, l_agdsp — rollback
# locations 11..15). We ship vbmeta with verification disabled (flags 3).
# TODO(firmware): if the bootloader insists on chain descriptors for the
# modem partitions, add --chain_partition for them with the stock pubkeys.
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_VBMETA_SYSTEM := product system system_ext
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

# VINTF
DEVICE_MANIFEST_FILE += \
    $(DEVICE_PATH)/configs/vintf/manifest.xml \
    $(DEVICE_PATH)/configs/vintf/manifest_nfc.xml

# Properties
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/configs/props/product.prop
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/configs/props/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/configs/props/vendor.prop

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/public

# Inherit the proprietary files
include vendor/realme/RMX3511/BoardConfigVendor.mk
