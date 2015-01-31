#!/bin/bash
#dracut -N  -f -m "base busybox uird magos-soft network ntfs url-lib ifcfg"  \
dracut -N  -f -m ""  \
        --confdir "dracut.conf.d" \
        -i "kernel" "/"  \
        -c dracut_configs.conf -v -M uird.kernel.cpio.xz $(uname -r) >dracut_kernel.log 2>&1


