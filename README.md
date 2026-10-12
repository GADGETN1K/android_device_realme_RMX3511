# Device tree для realme C35 (RMX3511)

| | |
|---|---|
| SoC | Unisoc Tiger T616 (ums9230), 2× Cortex-A75 + 6× Cortex-A55 |
| GPU | Mali-G57 MP1 |
| Экран | 6.6" IPS, 1080×2408 |
| Сток | Android 11 (realme UI 2.0) → Android 13 (realme UI 4.0) |
| Разделы | dynamic + Virtual A/B |
| Ядро | 5.4.254, исходники от realme |
| Цель | LineageOS 23 (Android 16), затем 17.0 |

## Статус

Скелет. Не собирается, пока не заполнены строки `TODO(dump)` — BoardConfig
специально падает с `$(error ...)` без размеров разделов.

## Порядок работы

1. **Разблокировка.** У realme нет официального анлока для C35; рабочий путь —
   CVE-2022-38694 (TomKing062, ums9230 в списке поддержки).
2. **Дамп стока.** Последняя прошивка realme UI 4.0 (PAC) → `dumpyard`/`DumprX`.
3. **Сбор значений:** `tools/collect-from-dump.sh <dump>` — fstab, cmdline и
   header version, modules.load, lpdump, список HAL.
4. **Ядро** — см. `docs/kernel.md`.
5. **Блобы:** заполнить `proprietary-files.txt`, `./extract-files.py <dump>`.
6. Первый бут с `androidboot.selinux=permissive`, логи, затем sepolicy.

## Ветки

- `lineage-23.0` — Android 16
- `lineage-23.2` / 17.0 — после того как 16 загрузится
