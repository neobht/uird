#!/bin/bash
rm -rf /usr/lib/dracut/modules.d/97uird /usr/lib/dracut/modules.d/98uird-soft /usr/lib/dracut/modules.d/90ntfs
cp -pRf modules.d/* /usr/lib/dracut/modules.d

#dracut -N  -f -m "base busybox uird magos-soft network ntfs url-lib ifcfg"  \
dracut -N  -f -m "uird-soft"  \
        --confdir "dracut.conf.d" \
        -c dracut.conf -v -M uird.soft.cpio.xz $(uname -r) >dracut.log 2>&1


