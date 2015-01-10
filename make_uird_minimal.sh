#!/bin/bash
rm -rf /usr/lib/dracut/modules.d/97uird /usr/lib/dracut/modules.d/98magos-soft /usr/lib/dracut/modules.d/90ntfs
cp -pRf modules.d/* /usr/lib/dracut/modules.d

#dracut -N  -f -m "base busybox uird magos-soft network ntfs url-lib ifcfg"  \
dracut -N  -f -m "base busybox uird ntfs kernel-modules"  \
	-d "loop cryptoloop aes-generic aes-i586" \
        --filesystems "aufs squashfs vfat msdos iso9660 isofs xfs ext3 ext4 fuse nfs cifs" \
        --confdir "dracut.conf.d" \
        -i initrd / \
        --kernel-cmdline "uird.from=/MagOS uird.ro=*.xzm uird.load=/base/" \
        -c dracut.conf -v -M uird.cpio.xz $(uname -r) >dracut.log 2>&1


