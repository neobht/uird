#!/bin/bash
#rm -rf /usr/lib/dracut/modules.d/97uird /usr/lib/dracut/modules.d/98magos-soft /usr/lib/dracut/modules.d/90ntfs
#cp -pRf modules.d/* /usr/lib/dracut/modules.d

#dracut -N  -f -m "base busybox uird magos-soft network ntfs url-lib ifcfg"  \
dracut -N  -f -m ""  \
        --confdir "dracut.conf.d" \
        -i "configs/basecfg.ini" "/basecfg.ini"  \
        -c dracut_configs.conf -v -M uird.configs.cpio.xz $(uname -r) >dracut_configs.log 2>&1


