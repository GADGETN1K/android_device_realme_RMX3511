#!/usr/bin/env bash
#
# Collect the values BoardConfig.mk / device.mk need from a stock dump.
#
# Usage: tools/collect-from-dump.sh <dump_dir>
#   <dump_dir> — output of dumpyard / DumprX for the stock realme UI 4.0
#   (Android 13) RMX3511 firmware, with vendor/, odm/, system/ unpacked
#   and boot.img, vendor_boot.img, dtbo.img, super.img (or lpdump) present.
#
# Writes into the device tree:
#   rootdir/etc/fstab.ums9230
#   modules.load, modules.load.vendor_boot
#   collected/  (cmdline, props, HAL list, partition info) for manual review

set -euo pipefail

DUMP="${1:?usage: $0 <dump_dir>}"
TREE="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$TREE/collected"
mkdir -p "$OUT" "$TREE/rootdir/etc"

prop() { grep -hs "^$1=" "$DUMP"/{system/system,system,vendor,odm,product}/build.prop 2>/dev/null | head -n1 | cut -d= -f2-; }

echo "== Identity"
for p in ro.product.vendor.device ro.product.board ro.board.platform ro.hardware \
         ro.build.fingerprint ro.build.description ro.product.product.name \
         ro.vendor.build.security_patch ro.product.first_api_level \
         ro.boot.dynamic_partitions ro.virtual_ab.enabled ro.virtual_ab.compression.enabled \
         ro.sf.lcd_density; do
    printf '%-40s %s\n' "$p" "$(prop "$p")"
done | tee "$OUT/props.txt"

echo "== fstab"
FSTAB="$(ls "$DUMP"/vendor/etc/fstab.ums9230_nico 2>/dev/null || ls "$DUMP"/vendor/etc/fstab.* 2>/dev/null | head -n1 || true)"
if [[ -n "$FSTAB" ]]; then
    cp -v "$FSTAB" "$OUT/$(basename "$FSTAB").stock"
    echo "   compare with rootdir/etc/fstab.ums9230_nico (sdcard voldmanaged line!)"
else
    echo "!! no vendor/etc/fstab.* in dump — check vendor_boot ramdisk"
fi

echo "== boot images"
for img in boot vendor_boot; do
    [[ -f "$DUMP/$img.img" ]] || { echo "!! $img.img missing"; continue; }
    if command -v unpack_bootimg >/dev/null; then
        unpack_bootimg --boot_img "$DUMP/$img.img" --out "$OUT/$img" --format=mkbootimg \
            > "$OUT/$img.args" 2>&1 || true
        echo "-- $img mkbootimg args:"; cat "$OUT/$img.args"
    else
        echo "!! unpack_bootimg not in PATH (out/host/linux-x86/bin after 'm unpack_bootimg')"
    fi
done

echo "== kernel modules load lists"
for src in "$DUMP"/vendor_dlkm/lib/modules/modules.load "$DUMP"/vendor/lib/modules/modules.load; do
    [[ -f "$src" ]] && cp -v "$src" "$TREE/modules.load" && break  # vendor_dlkm list
done

echo "== partitions"
if [[ -f "$DUMP/super.img" ]] && command -v lpdump >/dev/null; then
    lpdump "$DUMP/super.img" | tee "$OUT/lpdump.txt"
else
    echo "!! run 'lpdump' on device (adb shell lpdump) or on super.img and save to $OUT/lpdump.txt"
fi
ls -l "$DUMP"/*.img 2>/dev/null | tee "$OUT/images.txt" || true

echo "== VINTF HALs (vendor + odm manifests)"
grep -hoE '<name>[^<]+</name>' "$DUMP"/vendor/etc/vintf/manifest*.xml \
    "$DUMP"/vendor/etc/vintf/manifest/*.xml "$DUMP"/odm/etc/vintf/manifest*.xml 2>/dev/null \
    | sed 's/<\/*name>//g' | sort -u | tee "$OUT/hals.txt"

echo
echo "Done. Review $OUT and fill TODO(dump) lines in BoardConfig.mk / device.mk."
