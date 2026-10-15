# Source patches

Patches for other projects in the tree that this device needs and that are
not (yet) upstream. The directory layout mirrors the project path, e.g.
`patches/frameworks/opt/telephony/*.patch` is applied to
`frameworks/opt/telephony`.

They are applied with `git am` by `vendorsetup.sh` every time
`source build/envsetup.sh` runs. Patches that are already present are
skipped, so this is safe to repeat. After a `repo sync` the patches are
re-applied on the next `source build/envsetup.sh`.

| Project | Patch | Why |
|---|---|---|
| frameworks/opt/telephony | 0001-PhoneSwitcher-Only-fall-back-to-ALLOW_DATA-once-the-radio-is-on | The first DDS request after boot races the modem and gets `RADIO_NOT_AVAILABLE`; LineageOS then switches to `ALLOW_DATA` for good, which the Unisoc RIL does not implement, so mobile data on SIM 2 never works. |
