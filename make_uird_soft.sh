#!/bin/bash
#rm -rf /usr/lib/dracut/modules.d/*uird* /usr/lib/dracut/modules.d/*uird-soft* /usr/lib/dracut/modules.d/90ntfs
#cp -pRf modules.d/* /usr/lib/dracut/modules.d
cd dracut/modules.d
ln -s ../../modules.d/* ../modules.d/
cd ../..

./dracut/dracut.sh -l -N  -f -m "uird-soft"  \
        -c dracut.conf -v -M uird.soft.cpio.xz $(uname -r) >dracut_soft.log 2>&1


