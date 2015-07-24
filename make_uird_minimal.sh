#!/bin/bash
#rm -rf /usr/lib/dracut/modules.d/97uird
#cp -pRf modules.d/* /usr/lib/dracut/modules.d
cd dracut/modules.d
ln -s ../../modules.d/* ../modules.d/
cd ../..

./dracut/dracut.sh -l -N  -f -m "base uird"  \
        -i initrd / \
        --kernel-cmdline "uird.from=/MagOS,/MagOS-Data uird.ro=*.xzm,*.rom,*.rom.enc,*.pfs,*.sfs uird.rw=*.rwm,*.rwm.enc uird.load=/base/,/modules/,rootcopy uird.machines=/MagOS-Data/machines uird.config=MagOS.ini "\
        -c dracut.conf -v -M uird.minimal.cpio.xz $(uname -r) >dracut_minimal.log 2>&1
#        -c dracut.conf -v -M uird.minimal.cpio.xz 3.19.4-desktop586-2.mga5 >dracut_minimal.log 2>&1


