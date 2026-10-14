# What comes from source and what stays stock

Rule: an AOSP module replaces a stock blob only if no remaining prebuilt
links it with an incompatible ABI, or its interface is stable (HIDL/AIDL).
AOSP modules that are vendor-only but that our source-built vendor code
links (libeffects, keystore-wifi, codec2 plugin) are always built from source.

## Built from source
- All stable HIDL/AIDL interfaces (`android.hardware.*@x.y`, `android.hidl.*`,
  `android.frameworks.*`)
- boot (AIDL APEX), health (AIDL), fastbootd, DRM clearkey,
  wpa_supplicant/hostapd
- NFC: `hardware/nxp/nfc/pn8x` (`android.hardware.nfc@1.2-service`) with the
  stock `libnfc-nxp*.conf` (nico) in `/vendor/etc/`
- `audio.usb.default`, `audio.r_submix.default`
- libeffects (+ libeffectproxy), libcodec2_hidl_plugin,
  libkeystore-wifi-hidl, libkeystore-engine-wifi-hidl
- Permission/feature XMLs from `frameworks/native/data/etc`

## Dropped as unused
- Legacy `gralloc/power/thermal/vibrator/audio.primary.default`: nothing
  loads them
- Reference HALs `power.stats` and `rebootescrow`

## Stock
- Closed HALs: camera, RIL/IMS, primary audio, GNSS, WCN, Mali gralloc/HWC,
  sensors, fingerprint, Unisoc `vendor.sprd.*` services
- libtinycompress (only the stock audio HAL uses it; the AOSP one pulls
  arm64 kernel headers into its arm variant)
- BT audio (`audio.bluetooth.default` + `bluetooth.audio@2.1-impl`): stock BT
  stack is HIDL 2.1, the AOSP module is AIDL already
- Libraries renamed with `_rmx3511` where an AOSP module of the same name
  exists with a different ABI (see `proprietary-files.txt`)

## Compatibility with the S vendor
- `compat/ndk_platform`: `<aidl>-V<n>-ndk_platform` (S VNDK names) rebuilt
  from `<aidl>-V<n>-ndk`, so the blobs link without patching. keymint-V1 also
  carries RKP V1 (`IRemotelyProvisionedComponent` moved to
  `android.hardware.security.rkp`), and the imported AIDL types are linked
  as on S.
- `configs/vintf/framework_compatibility_matrix.xml`: the Unisoc
  `vendor.sprd.*` HIDL HALs as optional (stock system_ext declared them).
- Shims, added to DT_NEEDED in `extract-files.py`:
  - `libbase_shim` (hardware/lineage/compat): old Trim/Basename/
    WriteStringToFd overloads
  - `libbase_shim_rmx3511`: `android::base::Join<vector<string>, char>`
    (Mali allocator/mapper)
  - `libui_shim` (hardware/lineage/compat): old GraphicBufferMapper
    lock/unlock (camera HAL, HWC)
  - `libaeabi_shim_rmx3511`: `__aeabi_uidiv`/`__aeabi_uidivmod` (libdirac)
- Init scripts of five Unisoc HALs lose their `interface` lines: the HIDL
  interfaces are prebuilts unknown to host_init_verifier, and the services
  are not started on demand.

## KeyMint
The stock `android.hardware.security.keymint@1.0-unisoc.service` (Trusty) is
built against KeyMint V1 from S, while `libkeymint` and friends in 23.2 are
V4. The whole stack (8 libraries) is shipped from stock as `<lib>_rmx3511.so`
(file and soname), and the service and the libraries themselves are repointed
at them (`blob_fixups` in extract-files.py).

## TFLite
The Unisoc NN engine (`libunnengine`) needs the GPU delegate, which only the
stock `libtensorflowlite_c` exports; it is shipped as
`libtensorflowlite_c_rmx3511.so`.

## Later (after first boot)
- Wi-Fi: AOSP AIDL Wi-Fi HAL + `libwifi-hal-unisoc`
- Sensors through multihal
- BT audio on AIDL together with the BT HAL
- Wi-Fi overlays: stock ships Wi-Fi RROs as prebuilt APKs in
  `vendor/overlay/*/` (UnisocMarlin3WifiOverlayResources etc.). extract-utils
  doesn't handle APKs in vendor/overlay and APKs can't go into
  PRODUCT_COPY_FILES, so they are not shipped. Decompile them (`apktool d`)
  from the dump and recreate as source overlays (runtime_resource_overlay
  targeting `com.android.wifi.resources`).
