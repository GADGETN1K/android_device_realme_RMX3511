# Что из OSS, а что стоковое

Правило: OSS-модуль заменяет стоковый только если его не линкует ни один
закрытый блоб, либо у него стабильный ABI (HIDL/AIDL-интерфейсы).

## Из исходников
- Все стабильные HIDL/AIDL-интерфейсы (`android.hardware.*@x.y`, `android.hidl.*`,
  `android.frameworks.*`)
- boot (AIDL), health (AIDL), fastbootd, DRM clearkey, wpa_supplicant/hostapd
- NFC: `hardware/nxp/nfc/pn8x` (`android.hardware.nfc@1.2-service`), стоковые
  `libnfc-nxp*.conf` (nico) кладутся в `/vendor/etc/`
- `audio.usb.default`, `audio.r_submix.default`
- permission/feature XML из `frameworks/native/data/etc`

## Убрано как ненужное
- legacy `gralloc/power/thermal/vibrator/audio.primary.default` — их никто не грузит
- reference HAL `power.stats` и `rebootescrow`

## Стоковое (`_rmx3511`), пока не трогаем
- кодеки и codec2/stagefright, keymint и его зависимости, аудиофреймворк,
  `libwifi-hal`, `libchrome`, BT audio (`audio.bluetooth.default` +
  `bluetooth.audio@2.1-impl`: стоковый BT-стек — HIDL 2.1, OSS-модуль уже на AIDL)
- закрытые HAL: камера, RIL/IMS, primary audio, GNSS, WCN, Mali, сенсоры, отпечаток

## Кандидаты на потом (после первого бута)
- Wi-Fi: AOSP AIDL Wi-Fi HAL + `libwifi-hal-unisoc`
- сенсоры через multihal
- BT audio на AIDL вместе с BT HAL

## Совместимость с vendor от S
- `compat/ndk_platform`: `<aidl>-V<n>-ndk_platform` (имена из VNDK S), собранные
  из `<aidl>-V<n>-ndk` — блобы линкуются к ним без патчинга

## TODO: Wi-Fi overlays
Stock ships Wi-Fi RROs as prebuilt APKs in vendor/overlay/*/
(UnisocMarlin3WifiOverlayResources и др.). extract-utils doesn't handle
APKs in vendor/overlay and APKs can't go into PRODUCT_COPY_FILES, so they
are not shipped. Decompile them (apktool d) from the dump and recreate as
source overlays (runtime_resource_overlay targeting com.android.wifi.resources).
