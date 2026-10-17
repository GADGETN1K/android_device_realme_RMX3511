# Source patches

Patches for other projects in the tree that this device needs and that are
not (yet) upstream. The directory layout mirrors the project path, e.g.
`patches/frameworks/opt/telephony/*.patch` is applied to
`frameworks/opt/telephony`.

They are applied with `git am` by `vendorsetup.sh` every time
`source build/envsetup.sh` runs. Patches that are already present are
skipped, so this is safe to repeat. After a `repo sync` the patches are
re-applied on the next `source build/envsetup.sh`.

| Project | Patch | Why |
|---|---|---|
| frameworks/opt/telephony | 0001-PhoneSwitcher-Only-fall-back-to-ALLOW_DATA-once-the-radio-is-on | The first DDS request after boot races the modem and gets `RADIO_NOT_AVAILABLE`; LineageOS then switches to `ALLOW_DATA` for good, which the Unisoc RIL does not implement, so mobile data on SIM 2 never works. |
| hardware/lineage/interfaces | 0001-power-libperfmgr-Let-the-device-provide-the-IPower-b | The stock Unisoc blobs (hwcomposer, camera, codec2, RIL, audio) reach the power HAL through `libpowerhal_cli`, which takes Unisoc's `IVendorPower` from the IPower binder extension. This adds a weak hook so `power/` (`libperfmgr-ext-rmx3511`) can serve that extension instead of the Pixel `IPowerExt`. |
| packages/modules/Bluetooth | 0001-btif-a2dp-Double-the-A2DP-source-TX-queue | Wi-Fi and Bluetooth share one 2.4 GHz antenna on the Marlin3 Lite. Busy Wi-Fi stalls the A2DP link for up to ~200 ms, longer than the 28-frame TX queue covers, so the queue overflowed and was flushed (audible dropouts). The queue now holds 56 frames. |
| packages/modules/Bluetooth | 0002-stack-a2dp-Encode-SBC-at-229-kbps-by-default | Same cause: at 328 kbps (bitpool 53) the link still could not keep up while Wi-Fi was busy. 229 kbps, the rate AOSP already uses for non-EDR peers, needs about 30% less airtime; with both patches the queue no longer gets flushed. |
| frameworks/base | 0001-SystemUI-ax-Listen-for-access-points-only-while-the- | The AxionOS platform hooks kept an AccessPointController callback registered at all times, so SystemUI ran a full Wi-Fi scan every 10 seconds. Each scan holds the shared 2.4 GHz antenna for several seconds and broke up Bluetooth audio. Access points are now only tracked while the shade is open. |
