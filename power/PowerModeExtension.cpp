/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <aidl/android/hardware/power/BnPower.h>
#include <android/binder_ibinder.h>

#include "VendorPower.h"

namespace aidl {
namespace google {
namespace hardware {
namespace power {
namespace impl {
namespace pixel {

using ::aidl::android::hardware::power::Mode;

// No device-specific modes; same as Lineage's default libperfmgr-ext.
bool isDeviceSpecificModeSupported(Mode type, bool* _aidl_return) {
    (void)type;
    (void)_aidl_return;
    return false;
}

bool setDeviceSpecificMode(Mode type, bool enabled) {
    (void)type;
    (void)enabled;
    return false;
}

// Binder extension of the IPower service, used by service.cpp in place of
// the Pixel IPowerExt (see patches/hardware/lineage/interfaces).
ndk::SpAIBinder createDeviceSpecificExtension() {
    static std::shared_ptr<::vendor::rmx3511::power::VendorPower> ext =
            ndk::SharedRefBase::make<::vendor::rmx3511::power::VendorPower>();
    return ext->asBinder();
}

}  // namespace pixel
}  // namespace impl
}  // namespace power
}  // namespace hardware
}  // namespace google
}  // namespace aidl
