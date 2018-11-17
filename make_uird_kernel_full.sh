#!/bin/bash
cd dracut/modules.d
ln -s ../../modules.d/* ../modules.d/ 2>/dev/null
cd ../..
./dracut/dracut.sh -l -N -f -m "kernel-modules kernel-network-modules" \
	--kernel-only \
	-c dracut.conf -v -M uird.kernel_full.cpio.xz $(uname -r) >dracut_kernel_full.log 2>&1
