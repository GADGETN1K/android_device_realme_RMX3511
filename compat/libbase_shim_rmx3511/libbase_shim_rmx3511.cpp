/*
 * SPDX-FileCopyrightText: 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <string>
#include <vector>

#include <android-base/strings.h>

namespace android {
namespace base {

// _ZN7android4base4JoinINSt3__16vectorINS2_12basic_stringIcNS2_11char_traitsIcEENS2_9allocatorIcEEEENS7_IS9_EEEEcEES9_RKT_T0_
template __attribute__((visibility("default"))) std::string
Join<std::vector<std::string>, char>(const std::vector<std::string>&, char);

}  // namespace base
}  // namespace android
