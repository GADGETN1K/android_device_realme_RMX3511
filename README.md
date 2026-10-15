# Device tree for realme C35 (RMX3511)

| | |
|---|---|
| SoC | Unisoc Tiger T616 (ums9230), 2× Cortex-A75 + 6× Cortex-A55 |
| GPU | Mali-G57 MP1 |
| Display | 6.6" IPS, 1080×2408 |
| Stock | Android 11 (realme UI 2.0) → Android 13 (realme UI 4.0); this tree is based on 13.F.54 Global |
| Codenames | `RMX3511` (model), `RE87BAL1` (device), `ums9230_nico` (board) |
| Partitions | dynamic + Virtual A/B |
| Kernel | android12-5.4 from realme's source, merged up to 5.4.302, with KernelSU-Next (`5.4.302-CyberDrakons-Kernel`) |

## Branches

| Branch | Base | Android |
|---|---|---|
| `16.0` | lineage-23.2 (crDroid 12) | 16 |
| `17.0` | lineage-24.0 | 17 (after 16 boots) |

Dependencies (`lineage.dependencies` / `crdroid.dependencies`):

- [GADGETN1K/android_kernel_realme_RMX3511](https://github.com/GADGETN1K/android_kernel_realme_RMX3511), branch `16.0`
- [GADGETN1K/proprietary_vendor_realme_RMX3511](https://github.com/GADGETN1K/proprietary_vendor_realme_RMX3511), branch `16.0`

## Status

Boots crDroid 12 (Android 16), SELinux enforcing, GApps flashable.

Working:

- Display, touch, brightness, PQ (display enhancement), rotation
- Calls, SMS, USSD, mobile data on both SIMs (DSDS)
- Wi-Fi, Bluetooth, GPS, NFC
- Camera, audio, video playback/recording
- Fingerprint (side-mounted, with the SystemUI sensor location)
- Charging, fast charging, USB (MTP, adb), thermal
- Sensors, vibrator, lights
- Power HAL: Pixel libperfmgr with ADPF hint sessions (see below)
- Root: KernelSU-Next is built into the kernel

Not working / not done:

- IMS (VoLTE, VoWiFi)

How it is put together:

- Partition layout, boot/vendor_boot (header v4, recovery in vendor_boot),
  AVB, fstab, board init scripts: from the stock 13.F.54 PAC and dump.
  dm-verity is off on the logical partitions so GApps can be flashed on top;
  the stock signed vbmeta flags can't be changed.
- Kernel and all modules built from source, including the out-of-tree ones
  (camera, Mali, BT/FM, fingerprint, touch, NFC); see `docs/kernel.md`.
- Vendor blobs from 13.F.54 (`proprietary-files.txt`, ~1400 files) plus the
  radio/DSP/WCN/GNSS images (`proprietary-firmware.txt`). What was dropped
  from the stock list and why: `docs/blobs-dropped.txt`. Which parts come from
  source and which stay stock: `docs/oss.md`.
- SELinux: the stock vendor policy (platform 31.0 CIL) is converted to `.te`
  by `tools/selinux/cil2te.py` (`sepolicy/vendor/stock_vendor.te` and the
  contexts files), with device fixes in `sepolicy/vendor/rmx3511.te`; see
  `tools/selinux/README.md`.

### Power HAL

`android.hardware.power-service.lineage-libperfmgr` replaces the stock
`vendor.unisoc.hardware.power-service`. `configs/power/powerhint.json`
follows the stock `power_scene_config.xml`: CPU floors on both clusters,
top-app uclamp, the Mali devfreq floor (T616 table: 384-750 MHz) and the DDR
"boost" scene vote, plus an ADPF profile.

The stock blobs (hwcomposer, camera, codec2, RIL, audio) don't call IPower
themselves: `libpowerhal_cli.so` takes Unisoc's `IVendorPower` from the
IPower binder extension. `power/` rebuilds that interface from the stock
NDK library and serves it from libperfmgr, mapping each stock scene
(`camera_perf`, `video_60fps`, ...) to a `SCENE_<name>` hint in
`powerhint.json`.

### Patches to other projects

`patches/<project path>/*.patch` are applied with `git am` by
`vendorsetup.sh` on every `source build/envsetup.sh` (already applied ones
are skipped). See `patches/README.md`:

- `frameworks/opt/telephony`: don't give up on the DDS switch when the first
  request races the modem (mobile data on SIM 2).
- `hardware/lineage/interfaces`: let the device serve its own IPower binder
  extension from libperfmgr.

## Requirements

The device must run stock **realme UI 4.0, 13.F.54** before flashing: the
vendor blobs, modem images and the bootloader/TEE requirements come from it.
From Android 11 firmware, flash the 13.F.54 PAC first.

When flashing a PAC, never write `ocdt`, `prodnv`, `miscdata`, `l_fixnv*`,
`l_runtimenv*`, `persist` or `splloader` (calibration, IMEI, project config).

## Bring-up workflow

1. **Unlock.** realme has no official unlock for the C35; the working way is
   CVE-2022-38694 (TomKing062, ums9230 is supported).
2. **Stock dump.** Latest realme UI 4.0 PAC → `DumprX`/`dumpyard`.
3. **Collect values:** `tools/collect-from-dump.sh <dump>` (props, lpdump, HAL
   list); `tools/pac-firmware.sh <pac_dir> <dump>` stages the firmware images
   under partition names for `proprietary-firmware.txt`.
4. **Blobs:** `./extract-files.py <dump>`. All fixups (renames, shims, soname
   and init script fixes) are applied there. `./setup-makefiles.py` only
   regenerates the vendor makefiles; `tools/drop-vendor-modules.py` removes
   modules from an already extracted vendor tree.
5. **Build:** `breakfast RMX3511 && m bacon`. `NINJA_ARGS="-k 0"` collects all
   `check_elf_file` errors in one run (see `out/error.log`).
6. **SELinux:** to port a newer stock policy, see `tools/selinux/README.md`.
