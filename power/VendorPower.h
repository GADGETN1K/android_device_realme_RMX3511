/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#include <aidl/vendor/unisoc/hardware/power/BnVendorPower.h>
#include <android/binder_ibinder.h>

#include <map>
#include <mutex>
#include <string>
#include <vector>

namespace vendor {
namespace rmx3511 {
namespace power {

// Unisoc's IVendorPower on top of libperfmgr. A scene "<name>" (stock
// power_scene_id_define.txt, e.g. camera_perf, video_60fps) is the
// libperfmgr hint "SCENE_<name>" from powerhint.json. Scenes without such
// a hint are accepted and ignored. Requests are counted per client token,
// and a client's requests are dropped when its token dies.
class VendorPower : public ::aidl::vendor::unisoc::hardware::power::BnVendorPower {
  public:
    VendorPower();
    ~VendorPower() override;

    ndk::ScopedAStatus acquirePowerHintBySceneId(const ndk::SpAIBinder& token,
                                                 const std::string& tag,
                                                 int32_t sceneId) override;
    ndk::ScopedAStatus releasePowerHintBySceneId(const ndk::SpAIBinder& token,
                                                 const std::string& tag,
                                                 int32_t sceneId) override;
    ndk::ScopedAStatus acquirePowerHintBySceneName(const ndk::SpAIBinder& token,
                                                   const std::string& tag,
                                                   const std::string& sceneName) override;
    ndk::ScopedAStatus releasePowerHintBySceneName(const ndk::SpAIBinder& token,
                                                   const std::string& tag,
                                                   const std::string& sceneName) override;
    ndk::ScopedAStatus getSceneIdByName(const std::string& sceneName,
                                        int32_t* _aidl_return) override;
    ndk::ScopedAStatus controlPowerHint(int32_t enable) override;
    ndk::ScopedAStatus registerPowerHintScene(const std::string& tag,
                                              const std::vector<std::string>& configs,
                                              int32_t* _aidl_return) override;
    ndk::ScopedAStatus unregisterPowerHintScene(const std::string& tag,
                                                int32_t sceneId) override;
    binder_status_t dump(int fd, const char** args, uint32_t numArgs) override;

  private:
    void acquire(const ndk::SpAIBinder& token, const std::string& tag, const std::string& scene);
    void release(const ndk::SpAIBinder& token, const std::string& tag, const std::string& scene);
    void onTokenDied(AIBinder* token);
    void startHint(const std::string& scene);
    void endHint(const std::string& scene);
    std::string nameForId(int32_t sceneId) const;
    static void binderDied(void* cookie);
    static void binderUnlinked(void* cookie);

    struct DeathCookie {
        VendorPower* self;
        AIBinder* token;
    };

    std::mutex mLock;
    std::map<int32_t, std::string> mIdToName;
    std::map<std::string, int32_t> mNameToId;
    // scene -> number of outstanding acquires over all clients
    std::map<std::string, int> mSceneCount;
    // client token -> scenes it holds (one entry per acquire)
    std::map<AIBinder*, std::vector<std::string>> mTokenScenes;
    std::map<AIBinder*, DeathCookie*> mCookies;
    AIBinder_DeathRecipient* mDeathRecipient;
    bool mEnabled = true;
};

}  // namespace power
}  // namespace rmx3511
}  // namespace vendor
