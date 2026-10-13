#!/usr/bin/env bash
#
# List vendor/realme/RMX3511 blob modules whose names are also defined by
# source modules elsewhere in the tree (=> "partition is different" or
# "module already defined" errors from soong).
#
# Usage (from the top of the source tree): device/realme/RMX3511/tools/find-clashes.sh
# Output: one line per clash: <module> <Android.bp that defines it>

set -euo pipefail

TOP="${TOP:-$PWD}"
VBP="$TOP/vendor/realme/RMX3511/Android.bp"
[[ -f "$VBP" ]] || { echo "run extract-files.py first ($VBP missing)" >&2; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

grep -oE '^\s*name: "[^"]+"' "$VBP" | sed -E 's/.*"([^"]+)"/\1/' | sort -u > "$tmp/vendor"

find "$TOP" \( -path "$TOP/out" -o -path "$TOP/.repo" -o -path "$TOP/vendor/realme" \
        -o -path "$TOP/prebuilts" -o -path "$TOP/kernel" -o -name .git \) -prune \
     -o -name Android.bp -print0 \
  | xargs -0 grep -HoE '^\s*name: "[^"]+"' 2>/dev/null \
  | sed -E 's#^([^:]+):\s*name: "([^"]+)"#\2 \1#' \
  | sort -k1,1 > "$tmp/tree"

join -j1 "$tmp/vendor" "$tmp/tree" | sed "s# $TOP/# #"
