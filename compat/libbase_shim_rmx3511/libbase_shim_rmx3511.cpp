/*
 * SPDX-FileCopyrightText: 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <string>
#include <vector>

#include <android-base/strings.h>

// S libbase exported Join<std::vector<std::string>, char> taking
// (const std::vector<std::string>&, char). Current libbase's Join takes a
// forwarding reference, so that instantiation can't be produced anymore;
// export a plain function under the old mangled name instead.
__attribute__((visibility("default"))) std::string JoinVectorChar(
        const std::vector<std::string>& things, char separator) __asm__(
        "_ZN7android4base4JoinINSt3__16vectorINS2_12basic_stringIcNS2_11char_traitsIcEENS2_"
        "9allocatorIcEEEENS7_IS9_EEEEcEES9_RKT_T0_");

std::string JoinVectorChar(const std::vector<std::string>& things, char separator) {
    return android::base::Join(things, separator);
}
