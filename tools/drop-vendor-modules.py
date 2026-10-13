#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Remove prebuilt modules from an already generated vendor/realme/RMX3511
# (Android.bp, RMX3511-vendor.mk, the blobs) after dropping them from
# proprietary-files.txt, without re-running extract-utils.
#
#   tools/drop-vendor-modules.py <vendor dir> libeffects libtinycompress ...

import os
import re
import sys


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__ or 'usage: drop-vendor-modules.py <vendor dir> <module>...')
    vendor, names = sys.argv[1], set(sys.argv[2:])

    bp = os.path.join(vendor, 'Android.bp')
    text = open(bp).read()
    blocks = re.split(r'(?m)^(?=\w+ \{)', text)
    kept, srcs = [], []
    for b in blocks:
        m = re.search(r'^\s*name:\s*"([^"]+)"', b, re.M)
        if m and m.group(1) in names:
            srcs += re.findall(r'"(proprietary/[^"]+)"', b)
            continue
        kept.append(b)
    open(bp, 'w').write(''.join(kept))
    print(f'Android.bp: removed {len(blocks) - len(kept)} module(s)')

    mk = os.path.join(vendor, 'RMX3511-vendor.mk')
    lines = open(mk).read().split('\n')
    out, removed = [], 0
    for line in lines:
        if line.strip().rstrip('\\').strip() in names:
            removed += 1
            # keep the list well-formed if this was its last entry
            if not line.rstrip().endswith('\\') and out and out[-1].rstrip().endswith('\\'):
                out[-1] = out[-1].rstrip().rstrip('\\').rstrip()
            continue
        out.append(line)
    open(mk, 'w').write('\n'.join(out))
    print(f'RMX3511-vendor.mk: removed {removed} PRODUCT_PACKAGES entr(y/ies)')

    for s in srcs:
        p = os.path.join(vendor, s)
        if os.path.exists(p):
            os.remove(p)
            print(f'deleted {s}')


if __name__ == '__main__':
    main()
