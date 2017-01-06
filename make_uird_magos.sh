#!/bin/bash
cd dracut/modules.d
ln -s ../../modules.d/* ../modules.d/ 2>/dev/null
cd ../..
./dracut/dracut.sh -l -N --strip -f -m "base uird uird-network ntfs kernel-modules kernel-network-modules"  \
	-d "loop cryptoloop zram aes-generic aes-i586 aes-x86_64 pata_acpi ata_generic ahci xhci-hcd xhci-pci xhci-plat-hcd ohci-pci \
	    usb-storage uhci-hcd hid usbhid ehci-hcd ohci-hcd ehci-pci ehci-platform hid-generic \
	    sr_mod sd_mod scsi_mod \ 
	    jbd jbd2 lockd evdev sunrpc \
	    af_packet \
	    =ide =ata =ethernet =usb/storage =usb/host =nfs" \
        --filesystems "aufs squashfs vfat msdos iso9660 isofs xfs ext3 fuse nfs cifs udf nls_cp866 nls_utf8 reiserfs overlay" \
        -i initrd / \
        -i configs / \
        -c dracut.conf -v -M uird.magos.cpio.xz $(uname -r)  >dracut_magos.log 2>&1

#        --kernel-cmdline "uird.from=/MagOS,/MagOS-Data uird.ro=*.xzm,*.rom,*.rom.enc,*.pfs,*.sfs uird.rw=*.rwm,*.rwm.enc uird.cp=*.xzm.cp,*/rootcopy uird.load=/base/,/modules/,rootcopy uird.machines=/MagOS-Data/machines uird.config=MagOS.ini" \
#        -c dracut.conf -v -M uird.magos.cpio.xz 3.19.4-desktop586-2.mga5 >dracut_magos.log 2>&1
