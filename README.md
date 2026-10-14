# Device tree for realme C35 (RMX3511)

| | |
|---|---|
| SoC | Unisoc Tiger T616 (ums9230), 2× Cortex-A75 + 6× Cortex-A55 |
| GPU | Mali-G57 MP1 |
| Display | 6.6" IPS, 1080×2408 |
| Stock | Android 11 (realme UI 2.0) → Android 13 (realme UI 4.0); this tree is based on 13.F.54 Global |
| Codenames | `RMX3511` (model), `RE87BAL1` (device), `ums9230_nico` (board) |
| Partitions | dynamic + Virtual A/B |
| Kernel | GKI android12-5.4, built from realme's 5.4.254 source |

## Branches

| Branch | Base | Android |
|---|---|---|
| `16.0` | lineage-23.2 (crDroid 12) | 16 |
| `17.0` | lineage-24.0 | 17 (after 16 boots) |

Dependencies (`lineage.dependencies` / `crdroid.dependencies`):

- [GADGETN1K/android_kernel_realme_RMX3511](https://github.com/GADGETN1K/android_kernel_realme_RMX3511), branch `16.0`
- [GADGETN1K/proprietary_vendor_realme_RMX3511](https://github.com/GADGETN1K/proprietary_vendor_realme_RMX3511), branch `16.0`

## Status

Builds a full OTA package; not booted yet.

- Partition layout, boot/vendor_boot (header v4, recovery in vendor_boot),
  AVB, fstab, board init scripts: from the stock 13.F.54 PAC and dump.
- Kernel and all modules built from source, including the out-of-tree ones
  (camera, Mali, BT/FM, fingerprint, touch, NFC); see `docs/kernel.md`.
- Vendor blobs from 13.F.54 (`proprietary-files.txt`, ~1400 files) plus the
  radio/DSP/WCN/GNSS images (`proprietary-firmware.txt`). What was dropped
  from the stock list and why: `docs/blobs-dropped.txt`. Which parts come from
  source and which stay stock: `docs/oss.md`.
- SELinux boots permissive (`androidboot.selinux=permissive`, userdebug only)
  until the device sepolicy covers the Unisoc HALs.

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
6. First boot permissive, collect logs, then write sepolicy.
