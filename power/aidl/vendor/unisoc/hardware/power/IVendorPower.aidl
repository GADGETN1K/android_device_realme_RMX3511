/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package vendor.unisoc.hardware.power;

/**
 * Unisoc's vendor extension of android.hardware.power.IPower, as used by
 * the stock libpowerhal_cli.so (hwcomposer, camera, codec2, RIL, audio).
 *
 * Reconstructed from the stock vendor.unisoc.hardware.power-V1-ndk_platform.so:
 * method order gives the transaction codes (1-8), the parcel calls give the
 * arguments, and the transact flags give oneway. The stock library is
 * vendor-stable (not VINTF), so this one is too.
 */
interface IVendorPower {
    oneway void acquirePowerHintBySceneId(IBinder token, String tag, int sceneId);
    oneway void releasePowerHintBySceneId(IBinder token, String tag, int sceneId);
    oneway void acquirePowerHintBySceneName(IBinder token, String tag, String sceneName);
    oneway void releasePowerHintBySceneName(IBinder token, String tag, String sceneName);
    int getSceneIdByName(String sceneName);
    void controlPowerHint(int enable);
    int registerPowerHintScene(String tag, in String[] configs);
    oneway void unregisterPowerHintScene(String tag, int sceneId);
}
