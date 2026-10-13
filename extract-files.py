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
        'android.hardware.audio.common-util',
        'android.hardware.audio.common@7.0-enums',
        'android.hardware.graphics.composer@2.1-resources',
        'audioclient-types-aidl-cpp',
        'av-types-aidl-cpp',
        'framework-permission-aidl-cpp',
        'lib_android_keymaster_keymint_utils',
        'libaudioclient_aidl_conversion',
        'libaudiofoundation',
        'libavservices_minijail',
        'libbinderdebug',
        'libbluetooth_audio_session',
        'libbt-vendor',
        'libcamera2ndk_vendor',
        'libchrome',
        'libcodec2_hidl@1.0',
        'libcodec2_hidl@1.1',
        'libcodec2_hidl_plugin',
        'libcodec2_vndk',
        'libcppbor_external',
        'libcppcose_rkp',
        'libdav1d',
        'libdrm',
        'libhidltransport',
        'libkeymaster_messages',
        'libkeymaster_portable',
        'libkeymint',
        'libkeystore-engine-wifi-hidl',
        'libkeystore-wifi-hidl',
        'libopus',
        'libpuresoftkeymasterdevice',
        'libsensorndkbridge',
        'libsfplugin_ccodec_utils',
        'libshmemcompat',
        'libshmemutil',
        'libsoft_attestation_cert',
        'libstagefright_amrnb_common',
        'libstagefright_bufferpool@2.0.1',
        'libstagefright_enc_common',
        'libstagefright_flacdec',
        'libstagefright_softomx',
        'libstagefright_softomx_plugin',
        'libstagefrighthw',
        'libtensorflowlite_c',
        'libtinycompress',
        'libtrusty',
        'libvibrator',
        'libvorbisidec',
        'libvpx',
        'libwifi-hal',
        'libz_stable',
        'shared-file-region-aidl-cpp',
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
