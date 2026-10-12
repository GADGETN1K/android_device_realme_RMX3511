# Разметка RMX3511 (по стоковому PAC 13.F.54 Global)

Источник: `ums9230_nico.xml`, `FileList.ini`, `PackInfo.csv` из PAC,
заголовки boot/vendor_boot/vbmeta. Продукт в PAC — `PAC_ums9230_nico`,
`ProductVersion=MocorDroid13`.

## Идентичность

| | |
|---|---|
| Fingerprint | `realme/RMX3511/RE87BAL1:13/TP1A.220624.014/R.202308310143:user/release-keys` |
| ro.product.device | `RE87BAL1` |
| Board / fstab suffix | `ums9230_nico` (а также `nico` в kernel diffconfig) |
| Vendor | Android 12 (`SP1A.210812.016`), заморожен (GRF) |
| Ядро стока | GKI `5.4.210-android12-9` (vermagic модулей vendor_boot) |
| Патч | 2023-08-05 |
| Проекты в PAC | `2171A`–`2171E`, `21724` (отличаются только `ocdt`) |

## Загрузочные образы

| | boot | vendor_boot |
|---|---|---|
| header | v4 | v4 |
| cmdline | пусто (GKI) | `console=ttyS1,115200n8 buildvariant=user` |
| base / page | — | `0x0` / 4096 |
| offsets | — | kernel `0x8000`, ramdisk `0x5400000`, tags `0x100`, dtb `0x1f00000` |
| ramdisk | generic, lz4-legacy | 688 файлов, lz4-legacy, 157 `.ko` |

DTB в vendor_boot — DT-таблица (mkdtimg) с одной записью, `sprd,ums9230`
("UMS9230 1H10 SoC"). DTBO — 21 оверлей (20 × `sprd,ums9230-4h10`, 1 ×
`sprd,ums9230-nico-go`).

## Разделы (МиБ)

| Раздел | Размер | A/B | Что это | В ROM |
|---|---|---|---|---|
| boot | 64 | да | GKI kernel + generic ramdisk | собираем |
| vendor_boot | 100 | да | vendor ramdisk, модули, DTB, recovery | собираем |
| dtbo | 8 | да | оверлеи | prebuilt со стока |
| vbmeta | 1 | да | | собираем |
| vbmeta_system | 1 | да | | собираем |
| vbmeta_vendor / _system_ext / _product / _odm | 1 | да | цепочки стока | не трогаем |
| super | 8000 | — | system, system_ext, product, vendor, vendor_dlkm (erofs) | собираем |
| l_modem | 25 | да | модем LTE | firmware |
| l_deltanv | 1 | да | дельта NV модема | firmware |
| l_ldsp / l_gdsp / l_agdsp | 20 / 10 / 6 | да | DSP | firmware |
| pm_sys | 1 | да | DFS / PM (Cortex-M) | firmware |
| gnssmodem | 1 | да | GNSS | firmware |
| wcnmodem | 10 | да | Wi-Fi/BT | firmware |
| uboot / sml / trustos / teecfg | 3 / 1 / 6 / 1 | да | загрузчик, монитор, TEE | **пока нет** |
| hypervsior | 10 | да | пуст в PAC | нет |
| socko / odmko | 75 / 25 | да | пусты в PAC | нет |
| ocdt | 1 | да | проектный конфиг OPLUS | **никогда** |
| l_fixnv1/2 | 2 | да | калибровки, IMEI | **никогда** |
| l_runtimenv1/2 | 2 | нет | runtime NV | **никогда** |
| prodnv | 10 | нет | калибровки (монтируется в /mnt/vendor) | **никогда** |
| miscdata | 1 | нет | phase check | **никогда** |
| persist | 2 | нет | | **никогда** |
| splloader | — | нет | SPL (mmcblk0boot0) | **никогда** |
| my_preload | 3400 | нет | предустановки OPLUS | нет |
| misc, metadata, cache, userdata, logo, fbootlogo, uboot_log, sysdumpdb, avbmeta_rs, common_rs1/2 | | | служебные | нет |

## Цепочка AVB стока

`vbmeta` → chain: `boot`(1), `vendor_boot`(18), `dtbo`(6), `vbmeta_system`(2),
`vbmeta_vendor`(4), `vbmeta_system_ext`(3), `vbmeta_product`(5), `l_modem`(11),
`l_ldsp`(12), `l_gdsp`(13), `pm_sys`(14), `l_agdsp`(15).
В скобках — rollback index location. Все rollback index в PAC = 1.

## Соответствие файлов PAC разделам

См. `tools/pac-firmware.sh`.
