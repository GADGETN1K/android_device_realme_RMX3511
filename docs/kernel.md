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

Для Lineage: `TARGET_KERNEL_CONFIG := sprd_qogirl6_defconfig vendor/RMX3511.config`.

- `sprd_qogirl6_defconfig` — готовый `.config` realme для C31/C33/C35
  (в нём уже есть SGM4154X/SGM41512, LCM bias, аудио sc2730, trusty, тачи).
- `vendor/RMX3511.config` — `ums9230_nico_diff_config` + user-diff, без MODULE_SIG.
- `sprd-gki-diff-config` как база не годится: это объединение всех платформ
  Unisoc (sharkl3/l5, ums512, ums9620…), с мёртвыми драйверами и без
  realme-специфичных символов.

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
  `modules.load.recovery` (156), `modules.load` для vendor_dlkm (118).
  Сток грузит vendor_dlkm скриптом `init.insmod.sh` по `init.insmod.cfg`;
  у нас — `modprobe --all=modules.load` из `init.ums9230_nico.rc`.
- Запасной путь для первого бута: стоковое GKI-ядро + стоковые `.ko`
  (vermagic совпадает) — если сборка из исходников затянется.

## Требования Android 16 к ядру

Сверить с `kernel/configs` в AOSP 16: eBPF для netd/bpfloader, PSI, cgroup v2,
userfaultfd для ART. Ветка android12-5.4 большую часть закрывает.
