# Ядро RMX3511

Источник: `realme-kernel-opensource/realme_C31_C33_C35_narzo50A-Prime-AndroidT-NEW-kernel-source`
(Linux 5.4.254, Unisoc GKI-стиль, один коммит, Android T).

Форкаем в `android_kernel_realme_RMX3511`, ветка `lineage-23.0`.

## Конфиг

Стоковый `build.config.gki_unisoc.aarch64` генерирует `sprd_gki_defconfig` на лету:
`gki_defconfig` → `scripts/sprd/sprd_create_user_config.sh` применяет
`Documentation/sprd-gki-diff-config` → копия в `arch/arm64/configs/sprd_gki_defconfig`.

Для Lineage делаем так:

1. Один раз прогоняем стоковый скрипт и сохраняем результат.
2. `scripts/diffconfig gki_defconfig sprd_gki_defconfig` → переводим в фрагмент
   `arch/arm64/configs/vendor/ums9230.config`.
3. Device-специфичные правки (realme-драйверы, KernelSU и т.п.) — в
   `arch/arm64/configs/vendor/RMX3511.config`.

BoardConfig уже ссылается на `gki_defconfig vendor/ums9230.config vendor/RMX3511.config`.

## Что проверить в первую очередь

- Собирается ли 5.4 текущим clang из Lineage 23; если нет — фиксы под новый clang
  или `TARGET_KERNEL_CLANG_VERSION` на более старый.
- Требования Android 16 к ядру для upgrade-устройств: eBPF (netd/`bpfloader`),
  `CONFIG_PSI`, cgroup v2, `memfd`, userfaultfd для ART. Сверить с
  `kernel/configs` в AOSP 16 и бэкпортировать недостающее.
- Out-of-tree модули из `kernel_modules/` (Mali, sprd wcn и т.д.) — собрать
  через `TARGET_KERNEL_EXT_MODULES` либо временно брать `.ko` со стока
  (vermagic должен совпасть).
- `modules.load` / `modules.load.vendor_boot` — со стока, `tools/collect-from-dump.sh`.
