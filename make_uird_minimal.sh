#!/bin/bash
rm -rf /usr/lib/dracut/modules.d/97uird
cp -pRf modules.d/* /usr/lib/dracut/modules.d

dracut -N  -f -m "base uird"  \
        --confdir "dracut.conf.d" \
        -i initrd / \
        --kernel-cmdline "uird.from=/MagOS,/MagOS-Data uird.ro=*.xzm,*.rom,*.rom.enc,*.pfs,*.sfs uird.rw=*.rwm,*.rwm.enc uird.load=* uird.noload=/optional/,/machines/,/homes/,/cache/ uird.machines=/MagOS-Data/machines" \
        -c dracut.conf -v -M uird.minimal.cpio.xz $(uname -r) >dracut.log 2>&1


