#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Apply the framework patches this device needs (see patches/README.md).
_rmx3511_top="$(gettop)"
bash "$_rmx3511_top/device/realme/RMX3511/tools/apply-patches.sh" \
    "$_rmx3511_top" "$_rmx3511_top/device/realme/RMX3511"
unset _rmx3511_top
