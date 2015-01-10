#!/bin/bash
rm -rf /usr/lib/dracut/modules.d/97uird /usr/lib/dracut/modules.d/90ntfs
cp -pRf modules.d/* /usr/lib/dracut/modules.d

dracut -N  -f -m "base busybox uird ntfs"  \
	-d "loop cryptoloop aes-generic aes-i586 pata_acpi ata_generic ahci xhci-hcd" \
        --filesystems "aufs squashfs vfat msdos iso9660 isofs xfs ext3 ext4 fuse nfs cifs" \
        --confdir "dracut.conf.d" \
        -i initrd / \
        --kernel-cmdline "uird.from=/MagOS,/MagOS-Data uird.ro=*.xzm,*.rom,*.rom.enc,*.pfs,*.sfs uird.rw=*.rwm,*.rwm.enc uird.load=* uird.noload=/optional/,/machines/,/homes/,/cache/ uird.machines=/MagOS-Data/machines" \
        -c dracut.conf -v -M uird.cpio.xz $(uname -r) >dracut.log 2>&1


