#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
]

def lib_fixup_rmx3511_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_rmx3511' if partition == 'vendor' else None


lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    # Linked (not dlopen'd) S blobs that share a name with AOSP modules;
    # see MODULE_SUFFIX=_rmx3511 in proprietary-files.txt
    (
        'libbt-vendor',
        'libdav1d',
        'libstagefrighthw',
        'libvibrator',
    ): lib_fixup_rmx3511_suffix,
}

# Unisoc blobs will need fixups (libutils/libhidlbase shims, removed
# symbols on Android 16); add them here as they surface in logcat.
blob_fixups: blob_fixups_user_type = {
}  # fmt: skip

module = ExtractUtilsModule(
    'RMX3511',
    'realme',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
    # proprietary-firmware.txt: radio/DSP/WCN/GNSS images from the stock PAC,
    # staged by tools/pac-firmware.sh
    add_firmware_proprietary_file=True,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
