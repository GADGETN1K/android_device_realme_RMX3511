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
| packages/modules/Bluetooth | 0003-btif-a2dp-Deepen-the-A2DP-source-TX-queue-to-112-fra | YouTube over Wi-Fi still caused stalls longer than 56 frames could cover. The queue now holds 112 frames (~1.3 s of SBC audio), so a coexistence stall no longer flushes it. |
| packages/modules/Bluetooth | 0004-btif-a2dp-Account-for-the-TX-queue-in-the-reported-d | A deeper queue adds latency that the audio HAL did not know about, so video drifted ahead of the sound. The source now tracks how much audio is waiting in the TX queue and adds it to the remote delay reported to the HAL; players use it in the presentation position, keeping A/V in sync. |
