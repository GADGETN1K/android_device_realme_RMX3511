#!/vendor/bin/sh
#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Load the vendor_dlkm modules, like stock init.insmod.sh + init.insmod.cfg
# ("modprobe|*", then "setprop|vendor.all.modules.ready"): the full list
# normally, the reduced one in off-mode charging.

dir=/vendor_dlkm/lib/modules
list=$dir/modules.load
if [ "$1" = "charger" ] && [ -f $dir/modules.load.charger ]; then
    list=$dir/modules.load.charger
fi

/vendor/bin/modprobe -s -a -d $dir $(cat $list)

# Unblock early-boot even if some modules failed
setprop vendor.all.modules.ready 1
