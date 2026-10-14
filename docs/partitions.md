# RMX3511 partition layout (stock 13.F.54 Global PAC)

Sources: `ums9230_nico.xml`, `FileList.ini`, `PackInfo.csv` from the PAC,
boot/vendor_boot/vbmeta headers. The PAC product is `PAC_ums9230_nico`,
`ProductVersion=MocorDroid13`.

## Identity

| | |
|---|---|
| Fingerprint | `realme/RMX3511/RE87BAL1:13/TP1A.220624.014/R.202308310143:user/release-keys` |
| ro.product.device | `RE87BAL1` |
| Board / fstab suffix | `ums9230_nico` (also `nico` in the kernel diffconfig) |
| Vendor | Android 12 (`SP1A.210812.016`), frozen (GRF) |
| Stock kernel | GKI `5.4.210-android12-9` (vermagic of the vendor_boot modules) |
| Security patch | 2023-08-05 |
| Projects in the PAC | `2171A`–`2171E`, `21724` (they differ only in `ocdt`) |

## Boot images

| | boot | vendor_boot |
|---|---|---|
| header | v4 | v4 |
| cmdline | empty (GKI) | `console=ttyS1,115200n8 buildvariant=user` |
| base / page | — | `0x0` / 4096 |
| offsets | — | kernel `0x8000`, ramdisk `0x5400000`, tags `0x100`, dtb `0x1f00000` |
| ramdisk | generic, lz4-legacy | 688 files, lz4-legacy, 157 `.ko`, recovery included |

The vendor_boot DTB is a DT table (mkdtimg) with one entry, `sprd,ums9230`
("UMS9230 1H10 SoC"). DTBO has 21 overlays (20 × `sprd,ums9230-4h10`, 1 ×
`sprd,ums9230-nico-go`).

## Partitions (MiB)

| Partition | Size | A/B | What | In the ROM |
|---|---|---|---|---|
| boot | 64 | yes | GKI kernel + generic ramdisk | built |
| vendor_boot | 100 | yes | vendor ramdisk, modules, DTB, recovery | built |
| dtbo | 8 | yes | overlays | stock prebuilt |
| vbmeta | 1 | yes | | built |
| vbmeta_system | 1 | yes | | built |
| vbmeta_vendor / _system_ext / _product / _odm | 1 | yes | stock chains | untouched |
| super | 8000 | — | system, system_ext, product, vendor, vendor_dlkm (erofs) | built |
| l_modem | 25 | yes | LTE modem | firmware |
| l_deltanv | 1 | yes | modem NV delta | firmware |
| l_ldsp / l_gdsp / l_agdsp | 20 / 10 / 6 | yes | DSPs | firmware |
| pm_sys | 1 | yes | DFS / PM (Cortex-M) | firmware |
| gnssmodem | 1 | yes | GNSS | firmware |
| wcnmodem | 10 | yes | Wi-Fi/BT | firmware |
| uboot / sml / trustos / teecfg | 3 / 1 / 6 / 1 | yes | bootloader, monitor, TEE | **not yet** |
| hypervsior | 10 | yes | empty in the PAC | no |
| socko / odmko | 75 / 25 | yes | empty in the PAC | no |
| ocdt | 1 | yes | OPLUS project config | **never** |
| l_fixnv1/2 | 2 | yes | calibration, IMEI | **never** |
| l_runtimenv1/2 | 2 | no | runtime NV | **never** |
| prodnv | 10 | no | calibration (mounted at /mnt/vendor) | **never** |
| miscdata | 1 | no | phase check | **never** |
| persist | 2 | no | | **never** |
| splloader | — | no | SPL (mmcblk0boot0) | **never** |
| my_preload | 3400 | no | OPLUS preloads | no |
| misc, metadata, cache, userdata, logo, fbootlogo, uboot_log, sysdumpdb, avbmeta_rs, common_rs1/2 | | | service partitions | no |

## Stock AVB chain

`vbmeta` → chain: `boot`(1), `vendor_boot`(18), `dtbo`(6), `vbmeta_system`(2),
`vbmeta_vendor`(4), `vbmeta_system_ext`(3), `vbmeta_product`(5), `l_modem`(11),
`l_ldsp`(12), `l_gdsp`(13), `pm_sys`(14), `l_agdsp`(15).
The numbers are rollback index locations. All rollback indexes in the PAC are 1.

## PAC files to partitions

See `tools/pac-firmware.sh`.
