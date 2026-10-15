# Stock vendor sepolicy port

`sepolicy/vendor/{stock_vendor.te,attributes,*_contexts}` are generated from
the stock RMX3511 vendor policy (platform 31.0) so the stock Unisoc/OPLUS
blobs get their own domains and labels.

Regenerate:

    D=<stock dump>/vendor/etc/selinux
    O=out/target/product/RMX3511/vendor/etc/selinux   # our last build
    python3 tools/selinux/cil2te.py $D/vendor_sepolicy.cil $O/plat_pub_versioned.cil $O/vendor_sepolicy.cil /tmp/gen system/sepolicy/private/genfs_contexts device/lineage/sepolicy/common/private/genfs_contexts
    for f in file property hwservice; do
        python3 tools/selinux/ctx.py $D/vendor_${f}_contexts $O/vendor_${f}_contexts /tmp/gen/stock_vendor.te /tmp/gen/${f}_contexts
    done
    python3 tools/selinux/ctx.py $D/vndservice_contexts - /tmp/gen/stock_vendor.te /tmp/gen/vndservice_contexts
    python3 tools/selinux/ctx.py $D/vendor_service_contexts - /tmp/gen/stock_vendor.te /tmp/gen/service_contexts

`cil2te.py` keeps only the types the stock vendor adds on top of AOSP, strips
the `_31_0` version suffixes and drops rules that name types which don't
exist on this platform (mostly stock system_ext daemons we don't ship).
`ctx.py` keeps the stock entries whose key our own policy doesn't label yet.
Hand-written fixes go in separate .te files, not in the generated ones.
