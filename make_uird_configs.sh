#!/bin/bash
cd configs
find . -xdev | sort -z | cpio -o -H newc | xz --check=crc32 --lzma2=dict=1MiB -T0 >../uird.configs.cpio.xz
#find . -print0 | sort -z | cpio -H newc -o | xz > ../uird.configs.cpio.xz

#cd dracut/modules.d
#ln -s ../../modules.d/* ../modules.d/ 2>/dev/null
#cd ../..

#./dracut/dracut.sh -l -N  -f -m "uird-configs"  \
#        -i "configs" /  \
#        --no-kernel \
#        -c dracut_configs.conf -v -M uird.configs.cpio.xz $(uname -r) >dracut_configs.log 2>&1
