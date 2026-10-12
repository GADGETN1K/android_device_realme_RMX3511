# Ядро RMX3511

## Что на стоке

Сток (13.F.54) — настоящий GKI: в `boot.img` лежит гугловое ядро
`5.4.210-android12-9`, cmdline пустой, вендорские модули (157 шт.) — в
vendor_boot, остальное — в `vendor_dlkm`.

## Исходники

`realme-kernel-opensource/realme_C31_C33_C35_narzo50A-Prime-AndroidT-NEW-kernel-source`
— та же ветка KMI (android12-5.4), но 5.4.254. Форкаем в
`android_kernel_realme_RMX3511`, ветка `lineage-23.0`.

Ещё стоит посмотреть `rifsxd/android_kernel_realme_RMX3511` — живой форк,
возможно, уже с фиксами под новый clang.

## Конфиг

`build.config.gki_unisoc.aarch64`: `gki_defconfig` →
`scripts/sprd/sprd_create_user_config.sh` + `Documentation/sprd-gki-diff-config`
(394 строки формата `ADD:/DEL:/MOD:CONFIG_*`).

Device-специфичное: `sprd-diffconfig/androids/qogirl6/arm64/ums9230_nico_diff_config`
(Wi-Fi/BT UMW2652 по SDIO, `CONFIG_OPLUS_DEVICE_IFNO`). Для androidt отдельного
nico-конфига нет.

Для Lineage:

1. Прогнать стоковый скрипт, сохранить `sprd_gki_defconfig`.
2. `scripts/diffconfig gki_defconfig sprd_gki_defconfig` → `arch/arm64/configs/vendor/ums9230.config`.
3. `ums9230_nico_diff_config` → `arch/arm64/configs/vendor/RMX3511.config`.

## DTB / DTBO — пока prebuilt

- Базовый DTB (`ums9230.dts`, "UMS9230 1H10 SoC") в исходниках есть, но в
  vendor_boot он упакован DT-таблицей (mkdtimg), поэтому сейчас берём стоковый
  `prebuilts/dtb/ums9230.dtb`.
- `ums9230-nico-overlay.dts` в исходниках есть (`sprd,sc-id = "ums9230 nico 1000"`,
  model "4H10 Board"), но **в Makefile для qogirl6 он не собирается**, а в
  стоковом dtbo 21 оверлей. Воспроизвести стоковый dtbo из этих исходников
  нельзя — используем `prebuilts/dtbo.img` (обрезан до `total_size`, без
  AVB-футера).

## Модули

- Out-of-tree: `kernel_modules/kernel5.4/{gpu,wcn,input,nfc,npu}` и
  `kernel_modules/common/camera`.
- Списки загрузки взяты со стока: `modules.load.vendor_boot` (69),
  `modules.load.recovery` (156). Для vendor_dlkm нужен дамп super.
- Запасной путь для первого бута: стоковое GKI-ядро + стоковые `.ko`
  (vermagic совпадает) — если сборка из исходников затянется.

## Требования Android 16 к ядру

Сверить с `kernel/configs` в AOSP 16: eBPF для netd/bpfloader, PSI, cgroup v2,
userfaultfd для ART. Ветка android12-5.4 большую часть закрывает.
