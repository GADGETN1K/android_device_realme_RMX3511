# Device tree для realme C35 (RMX3511)

| | |
|---|---|
| SoC | Unisoc Tiger T616 (ums9230), 2× Cortex-A75 + 6× Cortex-A55 |
| GPU | Mali-G57 MP1 |
| Экран | 6.6" IPS, 1080×2408 |
| Сток | Android 11 (realme UI 2.0) → Android 13 (realme UI 4.0), база дерева — 13.F.54 Global |
| Кодовые имена | `RMX3511` (модель), `RE87BAL1` (device), `ums9230_nico` (плата) |
| Разделы | dynamic + Virtual A/B |
| Ядро | GKI android12-5.4; исходники realme 5.4.254 |
| Цель | LineageOS 23 (Android 16), затем 17.0 |

## Статус

Разметка, заголовки boot/vendor_boot, AVB, fstab, списки модулей и
прошивочные образы заполнены по стоковому PAC (`docs/partitions.md`).
Осталось по дампу super: vendor/vendor_dlkm (блобы, второй fstab, vendor_dlkm
modules.load), подтверждение Virtual A/B через lpdump. Строки — `TODO(dump)`.

Минимальная прошивка для установки: **realme UI 4.0, 13.F.54**.

## Порядок работы

1. **Разблокировка.** У realme нет официального анлока для C35; рабочий путь —
   CVE-2022-38694 (TomKing062, ums9230 в списке поддержки).
2. **Дамп стока.** Последняя прошивка realme UI 4.0 (PAC) → `dumpyard`/`DumprX`.
3. **Сбор значений:** `tools/collect-from-dump.sh <dump>` — props, lpdump,
   список HAL; `tools/pac-firmware.sh <pac_dir> <dump>` — прошивочные образы
   под именами разделов для `proprietary-firmware.txt`.
4. **Ядро** — см. `docs/kernel.md`.
5. **Блобы:** заполнить `proprietary-files.txt`, `./extract-files.py <dump>`.
6. Первый бут с `androidboot.selinux=permissive`, логи, затем sepolicy.

## Ветки

- `lineage-23.0` — Android 16
- `lineage-23.2` / 17.0 — после того как 16 загрузится
