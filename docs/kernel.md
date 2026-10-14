# RMX3511 kernel

## Stock

Stock (13.F.54) is real GKI: `boot.img` carries Google's
`5.4.210-android12-9` kernel with an empty cmdline; vendor modules (157) are in
vendor_boot, the rest in `vendor_dlkm`.

## Source

[GADGETN1K/android_kernel_realme_RMX3511](https://github.com/GADGETN1K/android_kernel_realme_RMX3511),
branch `16.0`: a fork of
`realme-kernel-opensource/realme_C31_C33_C35_narzo50A-Prime-AndroidT-NEW-kernel-source`
(same KMI branch, android12-5.4, at 5.4.254) with build fixes for current
clang on top.

## Config

`TARGET_KERNEL_CONFIG := sprd_qogirl6_defconfig vendor/RMX3511.config`

- `sprd_qogirl6_defconfig` is realme's own full `.config` for C31/C33/C35. It
  already has the realme-specific drivers the stock modules need
  (SGM4154X/SGM41512 chargers, LCM bias, sc2730 audio, trusty, touch panels).
- `vendor/RMX3511.config` is the `ums9230_nico` delta
  (`sprd-diffconfig/androids/qogirl6/arm64/ums9230_nico_diff_config`: UMW2652
  Wi-Fi/BT over SDIO, `CONFIG_OPLUS_DEVICE_IFNO`) plus the user build delta,
  without `MODULE_SIG*`, and `SPRD_POWER_STAT_SHARKL6=m` as stock vendor_boot
  loads it as a module.
- `Documentation/sprd-gki-diff-config` is not usable as a base: it is the union
  of every Unisoc platform (sharkl3/l5, ums512, ums9620...), with dead drivers
  and without the realme-specific symbols.

`BoardConfig.mk` passes `CROSS_COMPILE`/`CROSS_COMPILE_COMPAT`: 5.4 only
derives clang's `--target` from them.

## DTB / DTBO: prebuilt for now

- The base DTB (`ums9230.dts`, "UMS9230 1H10 SoC") is in the source, but
  vendor_boot packs it as a DT table (mkdtimg), so the stock
  `prebuilts/dtb/ums9230.dtb` is used.
- `ums9230-nico-overlay.dts` is in the source (`sprd,sc-id = "ums9230 nico 1000"`,
  model "4H10 Board"), but the qogirl6 Makefile doesn't build it, while the
  stock dtbo has 21 overlays. The stock dtbo can't be reproduced from this
  source, so `prebuilts/dtbo.img` is used (trimmed to `total_size`, no AVB
  footer).

## Modules

- In-tree modules come from the kernel build.
- Out-of-tree modules (`kernel_modules/`) use Unisoc's BSP build flow; the
  `kernel_modules/rmx3511/Makefile` wrapper sets the board's `BSP_*` values and
  builds the 14 modules stock ships (camera, flash, Mali, microarray
  fingerprint, FT8756 touch, RF cable monitor, SN4V NFC, BT/FM). Lineage
  builds it via `TARGET_KERNEL_EXT_MODULES := rmx3511`. Warnings are not errors
  for these modules only (realme's Makefile has a global `-Werror`).
- Load lists are stock: `modules.load.vendor_boot` (69),
  `modules.load.recovery` (156), `modules.load` for vendor_dlkm (117: stock minus `hyb.ko`, see below) and
  `modules.load.charger` (51).
- `hyb.ko` (OPLUS hybridswap) is not loaded: its memcg vendor hook trips
  CFI (`mem_cgroup_alloc_hook [hyb]`) and panics the kernel as soon as init
  creates a memory cgroup. zram works without it.
- vendor_boot holds the union of the first two lists, with `modules.load`
  and `modules.load.recovery`, like stock (`BOOT_KERNEL_MODULES`).
- Stock loads vendor_dlkm with `init.insmod.sh` + `init.insmod.cfg`
  (`modprobe -a` over `modules.load`, or `modules.load.charger` in off-mode
  charging, then `vendor.all.modules.ready`). `rootdir/bin/init.modules.sh`
  does the same.

## Android 16 kernel requirements

To check against `kernel/configs` in AOSP 16: eBPF for netd/bpfloader, PSI,
cgroup v2. userfaultfd GC for ART: `MREMAP_DONTUNMAP` and minor faults are
backported in android12-5.4, so `PRODUCT_ENABLE_UFFD_GC := true`.
