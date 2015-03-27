#!/bin/bash
rm -rf /usr/lib/dracut/modules.d/*uird* /usr/lib/dracut/modules.d/90ntfs
cp -pRf modules.d/* /usr/lib/dracut/modules.d
#echo $(pwd)
dracut  -N  -f -m "base uird uird-network ntfs kernel-modules"  \
	-d "loop cryptoloop zram aes-generic aes-i586 pata_acpi ata_generic ahci xhci-hcd \
	    usb-storage uhci-hcd hid usbhid ehci-hcd ohci-hcd ehci-pci ehci-platform hid-generic \
	    sr_mod sd_mod scsi_mod \ 
	     jbd jbd2 lockd evdev sunrpc \
	    af_packet \
	    =ide =ata =ethernet =usb/storage =usb/host =nfs" \
        --filesystems "aufs squashfs vfat msdos iso9660 isofs xfs ext3 ext4 fuse nfs cifs udf nls_cp866 nls_utf8 " \
        --confdir "dracut.conf.d" \
        -i initrd / \
        --kernel-cmdline "uird.from=/MagOS,/MagOS-Data uird.ro=*.xzm,*.rom,*.rom.enc,*.pfs,*.sfs uird.rw=*.rwm,*.rwm.enc uird.cp=*.xzm.cp,*/rootcopy uird.load=/base/,/modules/,rootcopy uird.machines=/MagOS-Data/machines uird.config=MagOS.ini" \
        -c dracut.conf -v -M uird.magos.cpio.xz $(uname -r)  >dracut_magos.log 2>&1

#        -c dracut.conf -v -M uird.magos.cpio.xz 3.14.17-pf4 >dracut_magos.log 2>&1
