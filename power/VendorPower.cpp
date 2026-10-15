/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "powerhal-rmx3511"

#include "VendorPower.h"

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/stringprintf.h>
#include <android-base/strings.h>
#include <perfmgr/HintManager.h>

#include <algorithm>
#include <sstream>

namespace vendor {
namespace rmx3511 {
namespace power {

using ::android::perfmgr::HintManager;

namespace {

// Stock list of scene ids: "<id> <sub_id> <name>" per line, '#' comments.
constexpr char kSceneIdFile[] = "/vendor/etc/power_scene_id_define.txt";
constexpr char kHintPrefix[] = "SCENE_";

}  // namespace

VendorPower::VendorPower() {
    mDeathRecipient = AIBinder_DeathRecipient_new(binderDied);
    // The cookie is freed by libbinder_ndk's unlink callback, which runs
    // once per link (after binderDied, or when the link goes away).
    AIBinder_DeathRecipient_setOnUnlinked(mDeathRecipient, binderUnlinked);

    std::string content;
    if (!::android::base::ReadFileToString(kSceneIdFile, &content)) {
        LOG(WARNING) << "Failed to read " << kSceneIdFile << ", scene ids unknown";
        return;
    }
    for (const auto& line : ::android::base::Split(content, "\n")) {
        std::string l = ::android::base::Trim(line);
        if (l.empty() || l[0] == '#') continue;
        std::istringstream in(l);
        std::string id, subId, name;
        if (!(in >> id >> subId >> name)) continue;
        int32_t value = static_cast<int32_t>(std::stoul(id, nullptr, 16));
        mIdToName[value] = name;
        mNameToId[name] = value;
    }
    LOG(INFO) << "Loaded " << mIdToName.size() << " Unisoc power scenes";
}

VendorPower::~VendorPower() {
    AIBinder_DeathRecipient_delete(mDeathRecipient);
}

std::string VendorPower::nameForId(int32_t sceneId) const {
    auto it = mIdToName.find(sceneId);
    return it == mIdToName.end() ? ::android::base::StringPrintf("0x%08x", sceneId) : it->second;
}

void VendorPower::startHint(const std::string& scene) {
    const std::string hint = kHintPrefix + scene;
    HintManager* hm = HintManager::GetInstance();
    if (!mEnabled || !hm || !hm->IsHintSupported(hint)) return;
    hm->DoHint(hint);
}

void VendorPower::endHint(const std::string& scene) {
    const std::string hint = kHintPrefix + scene;
    HintManager* hm = HintManager::GetInstance();
    if (!hm || !hm->IsHintSupported(hint)) return;
    hm->EndHint(hint);
}

void VendorPower::acquire(const ndk::SpAIBinder& token, const std::string& tag,
                          const std::string& scene) {
    std::lock_guard<std::mutex> lock(mLock);
    LOG(DEBUG) << "acquire " << scene << " from " << tag;
    AIBinder* t = token.get();
    if (t != nullptr && mCookies.find(t) == mCookies.end()) {
        auto* cookie = new DeathCookie{this, t};
        AIBinder_incStrong(t);
        if (AIBinder_linkToDeath(t, mDeathRecipient, cookie) == STATUS_OK) {
            mCookies[t] = cookie;
        } else {
            // Local or already dead binder: still count it, just without
            // death tracking. Recent libbinder_ndk hands the cookie of a
            // failed link to binderUnlinked(), so don't free it here; on
            // older ones this leaks one small struct per failed link.
            AIBinder_decStrong(t);
        }
    }
    mTokenScenes[t].push_back(scene);
    if (mSceneCount[scene]++ == 0) startHint(scene);
}

void VendorPower::release(const ndk::SpAIBinder& token, const std::string& tag,
                          const std::string& scene) {
    std::lock_guard<std::mutex> lock(mLock);
    LOG(DEBUG) << "release " << scene << " from " << tag;
    auto it = mTokenScenes.find(token.get());
    if (it == mTokenScenes.end()) return;
    auto& scenes = it->second;
    auto pos = std::find(scenes.begin(), scenes.end(), scene);
    if (pos == scenes.end()) return;
    scenes.erase(pos);
    if (--mSceneCount[scene] == 0) {
        mSceneCount.erase(scene);
        endHint(scene);
    }
}

void VendorPower::binderDied(void* cookie) {
    auto* c = static_cast<DeathCookie*>(cookie);
    c->self->onTokenDied(c->token);
}

void VendorPower::binderUnlinked(void* cookie) {
    delete static_cast<DeathCookie*>(cookie);
}

void VendorPower::onTokenDied(AIBinder* token) {
    std::lock_guard<std::mutex> lock(mLock);
    auto it = mTokenScenes.find(token);
    if (it != mTokenScenes.end()) {
        for (const auto& scene : it->second) {
            if (--mSceneCount[scene] == 0) {
                mSceneCount.erase(scene);
                endHint(scene);
            }
        }
        mTokenScenes.erase(it);
    }
    auto c = mCookies.find(token);
    if (c != mCookies.end()) {
        // The cookie itself is freed in binderUnlinked().
        mCookies.erase(c);
        AIBinder_decStrong(token);
    }
}

ndk::ScopedAStatus VendorPower::acquirePowerHintBySceneId(const ndk::SpAIBinder& token,
                                                          const std::string& tag,
                                                          int32_t sceneId) {
    acquire(token, tag, nameForId(sceneId));
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus VendorPower::releasePowerHintBySceneId(const ndk::SpAIBinder& token,
                                                          const std::string& tag,
                                                          int32_t sceneId) {
    release(token, tag, nameForId(sceneId));
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus VendorPower::acquirePowerHintBySceneName(const ndk::SpAIBinder& token,
                                                            const std::string& tag,
                                                            const std::string& sceneName) {
    acquire(token, tag, sceneName);
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus VendorPower::releasePowerHintBySceneName(const ndk::SpAIBinder& token,
                                                            const std::string& tag,
                                                            const std::string& sceneName) {
    release(token, tag, sceneName);
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus VendorPower::getSceneIdByName(const std::string& sceneName,
                                                 int32_t* _aidl_return) {
    auto it = mNameToId.find(sceneName);
    *_aidl_return = it == mNameToId.end() ? -1 : it->second;
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus VendorPower::controlPowerHint(int32_t enable) {
    std::lock_guard<std::mutex> lock(mLock);
    LOG(INFO) << "controlPowerHint(" << enable << ")";
    mEnabled = enable != 0;
    if (!mEnabled) {
        for (const auto& [scene, count] : mSceneCount) endHint(scene);
    } else {
        for (const auto& [scene, count] : mSceneCount) startHint(scene);
    }
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus VendorPower::registerPowerHintScene(const std::string& tag,
                                                       const std::vector<std::string>& configs,
                                                       int32_t* _aidl_return) {
    // Runtime-defined scenes are not supported: everything is in powerhint.json.
    LOG(INFO) << "registerPowerHintScene from " << tag << " (" << configs.size()
              << " entries) not supported";
    *_aidl_return = -1;
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus VendorPower::unregisterPowerHintScene(const std::string& tag,
                                                         int32_t sceneId) {
    (void)tag;
    (void)sceneId;
    return ndk::ScopedAStatus::ok();
}

binder_status_t VendorPower::dump(int fd, const char**, uint32_t) {
    std::lock_guard<std::mutex> lock(mLock);
    std::string out = ::android::base::StringPrintf("Unisoc scenes: %s\n",
                                                    mEnabled ? "enabled" : "disabled");
    for (const auto& [scene, count] : mSceneCount) {
        out += ::android::base::StringPrintf("  %s x%d%s\n", scene.c_str(), count,
                                             HintManager::GetInstance()->IsHintSupported(
                                                     kHintPrefix + scene)
                                                     ? ""
                                                     : " (no hint, ignored)");
    }
    ::android::base::WriteStringToFd(out, fd);
    return STATUS_OK;
}

}  // namespace power
}  // namespace rmx3511
}  // namespace vendor
