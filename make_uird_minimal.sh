#!/bin/bash
cd dracut/modules.d
ln -s ../../modules.d/* ../modules.d/ 2>/dev/null
cd ../..

./dracut/dracut.sh -l -N -f -m "base uird" \
	-i initrd / \
	--kernel-cmdline "uird.from=/MagOS,/MagOS-Data uird.ro=*.xzm,*.rom,*.rom.enc,*.pfs,*.sfs uird.rw=*.rwm,*.rwm.enc uird.load=/base/,/modules/,rootcopy uird.machines=/MagOS-Data/machines uird.config=MagOS.ini " \
	--no-kernel \
	-c dracut.conf -v -M uird.minimal.cpio.xz $(uname -r) >dracut_minimal.log 2>&1
#        -c dracut.conf -v -M uird.minimal.cpio.xz 3.19.4-desktop586-2.mga5 >dracut_minimal.log 2>&1
