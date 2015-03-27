#!/bin/bash
rm -rf /usr/lib/dracut/modules.d/97uird
cp -pRf modules.d/* /usr/lib/dracut/modules.d

dracut -N  -f -m "base uird"  \
        -i initrd / \
        --confdir "dracut.conf.d" \
        --kernel-cmdline "uird.from=/MagOS,/MagOS-Data uird.ro=*.xzm,*.rom,*.rom.enc,*.pfs,*.sfs uird.rw=*.rwm,*.rwm.enc uird.load=/base/,/modules/,rootcopy uird.machines=/MagOS-Data/machines uird.config=MagOS.ini "\
        -c dracut.conf -v -M uird.minimal.cpio.xz $(uname -r) >dracut_minimal.log 2>&1


