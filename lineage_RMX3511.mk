#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from RMX3511 device
$(call inherit-product, device/realme/RMX3511/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_RMX3511
PRODUCT_DEVICE := RMX3511
PRODUCT_MANUFACTURER := realme
PRODUCT_BRAND := realme
PRODUCT_MODEL := RMX3511

PRODUCT_GMS_CLIENTID_BASE := android-oppo

# Stock RMX3511_13.F.54 (Global). Fingerprint from vbmeta_system.img;
# description is derived from it — TODO(dump): verify against build.prop.
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="RMX3511-user 13 TP1A.220624.014 R.202308310143 release-keys" \
    BuildFingerprint=realme/RMX3511/RE87BAL1:13/TP1A.220624.014/R.202308310143:user/release-keys \
    DeviceName=RE87BAL1 \
    DeviceProduct=RMX3511
