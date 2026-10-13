#!/bin/bash
#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Regenerate the vendor makefiles from proprietary-*.txt without extracting
# (no dump or adb needed). A regular file on purpose: as a symlink, writing
# to it would overwrite extract-files.py.
# extract-files.py finds extract-utils relative to the device directory.
cd "$(dirname "$(readlink -f "$0")")" || exit 1
exec ./extract-files.py --regenerate_makefiles "$@"
