#!/bin/bash
#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Apply the source patches under patches/<project path>/ to the tree.
# Safe to run repeatedly: a patch that is already in the project is skipped.
# Sourced from vendorsetup.sh, so it runs on every `source build/envsetup.sh`.

_rmx3511_apply_patches() {
    local top="$1" dev="$2" patch project rel subject
    [[ -d "$dev/patches" ]] || return 0

    while IFS= read -r -d '' patch; do
        rel="${patch#"$dev/patches/"}"
        project="$top/$(dirname "$rel")"
        if [[ ! -d "$project/.git" && ! -f "$project/.git" ]]; then
            echo "RMX3511 patches: $(dirname "$rel") is not a git project, skipping $(basename "$rel")"
            continue
        fi
        # Already applied? Match the commit subject first: a later patch that
        # touches the same lines makes the reverse check below fail even
        # though this one is in.
        subject="$(git mailinfo /dev/null /dev/null < "$patch" 2>/dev/null | sed -n 's/^Subject: //p')"
        if [[ -n "$subject" ]] && git -C "$project" log --format=%s -n 500 | grep -qxF -- "$subject"; then
            continue
        fi
        # ...or applied by hand or upstream under another subject
        if git -C "$project" apply --check --reverse "$patch" >/dev/null 2>&1; then
            continue
        fi
        if git -C "$project" am -q --3way --keep-cr "$patch" >/dev/null 2>&1; then
            echo "RMX3511 patches: applied $rel"
        else
            git -C "$project" am --abort >/dev/null 2>&1
            echo "RMX3511 patches: FAILED to apply $rel, fix it by hand"
        fi
    done < <(find "$dev/patches" -name '*.patch' -print0 | sort -z)
}

_rmx3511_apply_patches "$@"
unset -f _rmx3511_apply_patches
