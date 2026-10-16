/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <aidl/android/hardware/power/BnPower.h>
#include <android-base/file.h>
#include <android-base/logging.h>
#include <android/binder_ibinder.h>

#include "VendorPower.h"

namespace aidl {
namespace google {
namespace hardware {
namespace power {
namespace impl {
namespace pixel {

using ::aidl::android::hardware::power::Mode;

// Every touch driver the C35 ships (ilitek, chipone, himax, nt36xxx) exposes
// the same OPPO node; with it set, the panel stays in gesture mode while the
// screen is off and reports a double tap as KEY_POWER.
static constexpr const char* kDoubleTapNode = "/proc/touchpanel/double_tap_enable";
// The panels are TDDI: the display driver cuts the panel supplies on blank
// unless tp_gesture is set, which kills the touch controller as well. Only
// the ilitek driver sets it on its own, so set it here for all of them.
static constexpr const char* kPanelGestureNode = "/sys/kernel/oppo_display/tp_gesture";

static void writeNode(const char* path, bool enabled) {
    if (!::android::base::WriteStringToFile(enabled ? "1" : "0", path)) {
        PLOG(ERROR) << "Failed to write " << path;
    }
}

bool isDeviceSpecificModeSupported(Mode type, bool* _aidl_return) {
    if (type == Mode::DOUBLE_TAP_TO_WAKE) {
        *_aidl_return = true;
        return true;
    }
    return false;
}

bool setDeviceSpecificMode(Mode type, bool enabled) {
    if (type == Mode::DOUBLE_TAP_TO_WAKE) {
        writeNode(kPanelGestureNode, enabled);
        writeNode(kDoubleTapNode, enabled);
        return true;
    }
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
