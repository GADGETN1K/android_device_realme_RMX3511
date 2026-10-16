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

# Stock KeyMint stack (built against KeyMint V1 on S) is shipped renamed as
# <lib>_rmx3511.so; point the service and the stack itself at the copies.
KEYMINT_STACK = (
    'lib_android_keymaster_keymint_utils',
    'libcppbor_external',
    'libcppcose_rkp',
    'libkeymaster_messages',
    'libkeymaster_portable',
    'libkeymint',
    'libpuresoftkeymasterdevice',
    'libsoft_attestation_cert',
)


def keymint_stack_fixup():
    fixup = blob_fixup()
    for lib in KEYMINT_STACK:
        fixup = fixup.replace_needed(f'{lib}.so', f'{lib}_rmx3511.so')
    return fixup


blob_fixups: blob_fixups_user_type = {
    # libbase dropped the explicit Join<vector<string>, char> instantiation
    # these S blobs import; compat/libbase_shim_rmx3511 provides it.
    (
        'vendor/lib/hw/android.hardware.graphics.allocator@4.0-impl-arm.so',
        'vendor/lib64/hw/android.hardware.graphics.allocator@4.0-impl-arm.so',
        'vendor/lib/hw/android.hardware.graphics.mapper@4.0-impl-arm.so',
        'vendor/lib64/hw/android.hardware.graphics.mapper@4.0-impl-arm.so',
    ): blob_fixup().add_needed('libbase_shim_rmx3511.so'),
    # Old libbase overloads (Trim/Basename/WriteStringToFd taking
    # const std::string&); hardware/lineage/compat libbase_shim has them.
    (
        'vendor/bin/hw/vendor.sprd.hardware.broadcastradio@2.0-service',
        'vendor/bin/systemDebuggerd',
        'vendor/lib/hw/unisoc.bootctrl.so',
        'vendor/lib64/hw/unisoc.bootctrl.so',
        'vendor/lib/libavservices_minijail_vendor.so',
    ): blob_fixup().add_needed('libbase_shim.so'),
    # libdirac imports __aeabi_uidiv/__aeabi_uidivmod, no longer in libc.
    'vendor/lib/soundfx/libdirac.so': blob_fixup().add_needed('libaeabi_shim_rmx3511.so'),
    # AOSP's rild (from telephony_vendor.mk) defines vendor.ril-daemon too,
    # and its rild.rc is parsed first, so init ignored Unisoc's urild and
    # ran rild, which has no vendor RIL library and just sleeps. Make the
    # stock definition win.
    'vendor/etc/init/unisoc.rild.rc': blob_fixup().regex_replace(
        r'(?m)^(service vendor\.ril-daemon [^\n]*\n)', '\\1    override\n'
    ),
    # The Unisoc NN engine needs the GPU delegate from the stock TFLite C
    # library, which AOSP's libtensorflowlite_c doesn't export; ship the stock
    # one renamed.
    (
        'vendor/lib/libunnengine.so',
        'vendor/lib64/libunnengine.so',
    ): blob_fixup().replace_needed('libtensorflowlite_c.so', 'libtensorflowlite_c_rmx3511.so'),
    # Built against tinyxml2 from VNDK v31; today's libtinyxml2 has a
    # different ABI. See compat/libtxml2v31.
    (
        'vendor/bin/thermald',
        'vendor/bin/hw/vendor.sprd.hardware.cplog_svc@1.0-service',
        'vendor/bin/enhance_test',
        'vendor/lib64/libril-private.so',
        'vendor/lib64/camera.device@3.4-external-impl-sprd.so',
        'vendor/lib64/camera.device@3.5-external-impl-sprd.so',
        'vendor/lib64/libimpl-ril.so',
        'vendor/lib64/hw/enhance.ums9230.so',
        'vendor/lib64/hw/android.hardware.camera.provider@2.4-impl-sprd.so',
        'vendor/lib64/camera.device@3.6-external-impl-sprd.so',
        'vendor/lib64/android.hardware.camera.provider@2.4-external-sprd.so',
        'vendor/lib/libril-private.so',
        'vendor/lib/camera.device@3.4-external-impl-sprd.so',
        'vendor/lib/camera.device@3.5-external-impl-sprd.so',
        'vendor/lib/libimpl-ril.so',
        'vendor/lib/hw/enhance.ums9230.so',
        'vendor/lib/hw/android.hardware.camera.provider@2.4-impl-sprd.so',
        'vendor/lib/camera.device@3.6-external-impl-sprd.so',
        'vendor/lib/android.hardware.camera.provider@2.4-external-sprd.so',
    ): blob_fixup().replace_needed('libtinyxml2.so', 'libtxml2v31.so'),
    # S camera and HWC HALs use the old GraphicBufferMapper lock/unlock
    # signatures; hardware/lineage/compat libui_shim provides them.
    (
        'vendor/lib/hw/camera.ums9230.so',
        'vendor/lib64/hw/camera.ums9230.so',
        'vendor/lib/hw/hwcomposer.ums9230.so',
        'vendor/lib64/hw/hwcomposer.ums9230.so',
    ): blob_fixup().add_needed('libui_shim.so'),
    # Unisoc HALs come as prebuilts, so host_init_verifier doesn't know their
    # HIDL interfaces. The services are started by class/property, not on
    # demand, so the 'interface' lines are not needed.
    (
        'vendor/etc/init/vendor.sprd.hardware.ai_engine@1.0-service.rc',
        'vendor/etc/init/vendor.sprd.hardware.aprd@1.0-service.rc',
        'vendor/etc/init/vendor.sprd.hardware.commondcs@1.0-service.rc',
        'vendor/etc/init/vendor.sprd.hardware.cplog_svc@1.0-service.rc',
        'vendor/etc/init/vendor.sprd.hardware.fingerprintmmi@1.0-service.rc',
    ): blob_fixup().regex_replace(r'(?m)^[ \t]*interface vendor\.sprd\..*\n', ''),
    (
        'vendor/bin/hw/android.hardware.security.keymint@1.0-unisoc.service',
        *(f'vendor/lib64/{lib}_rmx3511.so' for lib in KEYMINT_STACK),
    ): keymint_stack_fixup(),
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
