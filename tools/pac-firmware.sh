#!/usr/bin/env bash
#
# Copy firmware images out of an unpacked RMX3511 PAC under their partition
# names, so extract-files.py can pick them up via proprietary-firmware.txt.
#
# Usage: tools/pac-firmware.sh <unpacked_pac_dir> <dump_dir>
#
# Mapping comes from the PAC's FileList.ini + ums9230_nico.xml
# (FileID -> file name -> partition).

set -euo pipefail

PAC="${1:?usage: $0 <unpacked_pac_dir> <dump_dir>}"
OUT="${2:?usage: $0 <unpacked_pac_dir> <dump_dir>}"
mkdir -p "$OUT"

declare -A MAP=(
    [l_modem]=SC9600_qogirl6_pubcp_SPA_modem.dat     # Modem_LTE
    [l_deltanv]=qogirl6_pubcp_SPA_deltanv.bin        # Modem_LTE_DELTANV
    [l_ldsp]=qogirl6_pubcp_SPA_LTEA_DSP.bin          # DSP_LTE_LTE
    [l_gdsp]=qogirl6_pubcp_SPA_DM_DSP.bin            # DSP_LTE_GGE
    [l_agdsp]=qogirl6_pubcp_SPA_AGCP_DSP.bin         # DSP_LTE_AG
    [pm_sys]=qogirl6_m3l_cm4_spa.bin                 # DFS
    [gnssmodem]=gnssmodem.bin                        # Modem_GNSS
    [wcnmodem]=EXEC_KERNEL_IMAGE.bin                 # Modem_WCN
)

missing=0
for part in "${!MAP[@]}"; do
    if [[ ! -f "$PAC/${MAP[$part]}" ]]; then
        echo "!! missing $PAC/${MAP[$part]} (for $part)" >&2
        missing=1
    fi
done
if (( missing )); then
    echo "!! nothing copied; files present in $PAC:" >&2
    ls -l "$PAC" >&2
    exit 1
fi

for part in "${!MAP[@]}"; do
    cp -v "$PAC/${MAP[$part]}" "$OUT/$part.img"
done

if [[ -f "$PAC/FileList.ini" ]]; then
    echo "-- PAC: $(grep -m1 '^ProductVersion' "$PAC/PackInfo.csv" 2>/dev/null || true)"
fi
