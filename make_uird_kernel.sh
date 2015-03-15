#!/bin/bash
#dracut -N  -f -m "base busybox uird magos-soft network ntfs url-lib ifcfg"  \
dracut -N  -f -m "kernel-modules"  \
	-d "loop cryptoloop zram aes-generic aes-i586 pata_acpi ata_generic ahci xhci-hcd \
	    usb-storage uhci-hcd hid usbhid ehci-hcd ohci-hcd ehci-pci ehci-platform hid-generic \
	    sr_mod sd_mod scsi_mod \ 
	     jbd jbd2 lockd evdev sunrpc \
	    af_packet \
	    =ide =ata =ethernet =usb/storage =usb/host =nfs" \
        --filesystems "aufs squashfs vfat msdos iso9660 isofs xfs ext3 ext4 fuse nfs cifs udf nls_cp866 nls_utf8 " \
        --confdir "dracut.conf.d" \
        -c dracut_configs.conf -v -M uird.kernel.cpio.xz $(uname -r) >dracut_kernel.log 2>&1


