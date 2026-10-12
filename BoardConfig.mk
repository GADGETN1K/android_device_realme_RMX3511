#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/realme/RMX3511

# Lines marked TODO(dump) must be filled from the stock realme UI 4.0
# (Android 13) dump. tools/collect-from-dump.sh prints most of them.

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
# TODO(dump): ro.product.board / ro.bootloader board name
TARGET_BOOTLOADER_BOARD_NAME := ums9230
TARGET_NO_BOOTLOADER := true

# A/B (Virtual A/B on stock)
AB_OTA_UPDATER := true
# TODO(dump): exact list from the partition table (lpdump + by-name)
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    odm \
    product \
    system \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot

# Kernel — built from source (realme 5.4.254 Unisoc GKI-style tree)
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_BASE := 0x00000000
# TODO(dump): verify with unpack_bootimg on stock boot/vendor_boot
BOARD_BOOT_HEADER_VERSION := 3
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
# TODO(dump): copy cmdline / offsets from unpack_bootimg output
BOARD_KERNEL_CMDLINE := console=ttyS1,115200n8 buildvariant=user
BOARD_VENDOR_CMDLINE := $(BOARD_KERNEL_CMDLINE)
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_KERNEL_SEPARATED_DTBO := true

TARGET_KERNEL_SOURCE := kernel/realme/RMX3511
# Stock flow generates sprd_gki_defconfig from gki_defconfig +
# Documentation/sprd-gki-diff-config. We keep that as a merged fragment
# list instead of committing a generated file (see docs/kernel.md).
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    vendor/ums9230.config \
    vendor/RMX3511.config
TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_NO_GCC := true

# Out-of-tree modules shipped in kernel_modules/ (GPU, Wi-Fi/BT, etc.)
# TODO(kernel): wire them up via TARGET_KERNEL_EXT_MODULES once the
# module list from stock vendor_boot/vendor_dlkm is known.

# Kernel modules load lists (copied from stock modules.load files)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(DEVICE_PATH)/modules.load.vendor_boot 2>/dev/null))
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(DEVICE_PATH)/modules.load 2>/dev/null))
BOOT_KERNEL_MODULES := $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD)

# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144
# TODO(dump): sizes from the partition table
# BOARD_BOOTIMAGE_PARTITION_SIZE :=
# BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE :=
# BOARD_DTBOIMG_PARTITION_SIZE :=
# BOARD_SUPER_PARTITION_SIZE :=
ifeq ($(BOARD_SUPER_PARTITION_SIZE),)
$(error RMX3511: fill partition sizes in BoardConfig.mk from the stock dump (tools/collect-from-dump.sh))
endif

BOARD_SUPER_PARTITION_GROUPS := main
# Virtual A/B: group max = super size - 4MiB overhead
BOARD_MAIN_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SIZE) - 4194304)
BOARD_MAIN_PARTITION_LIST := \
    odm \
    product \
    system \
    system_ext \
    vendor

BOARD_EXT4_SHARE_DUP_BLOCKS := true
TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor

BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.$(TARGET_BOARD_PLATFORM)
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
TARGET_NO_RECOVERY := true

# Screen
TARGET_SCREEN_DENSITY := 400

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_VBMETA_SYSTEM := product system system_ext
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 1

# VINTF
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/configs/vintf/manifest.xml

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/configs/props/odm.prop
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/configs/props/product.prop
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/configs/props/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/configs/props/vendor.prop

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/public

# Inherit the proprietary files
include vendor/realme/RMX3511/BoardConfigVendor.mk
