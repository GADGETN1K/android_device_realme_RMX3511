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

# TODO(dump): take PRODUCT_NAME / description / fingerprint from the
# latest stock (realme UI 4.0, Android 13) build.prop and fill in:
# PRODUCT_BUILD_PROP_OVERRIDES += \
#     BuildDesc="<ro.build.description>" \
#     BuildFingerprint=<ro.build.fingerprint> \
#     DeviceProduct=<ro.product.product.name>
