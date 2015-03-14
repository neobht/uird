#!/bin/bash
rm -rf /usr/lib/dracut/modules.d/00uird /usr/lib/dracut/modules.d/00uird-network /usr/lib/dracut/modules.d/90ntfs
cp -pRf modules.d/* /usr/lib/dracut/modules.d
#echo $(pwd)
dracut  -N  -f -m "bash base uird uird-network ntfs kernel-modules"  \
	-d "loop cryptoloop zram aes-generic aes-i586 pata_acpi ata_generic ahci xhci-hcd \
	    usb-storage uhci-hcd hid usbhid ehci-hcd ohci-hcd ehci-pci ehci-platform hid-generic \
	    sr_mod sd_mod scsi_mod \ 
	     jbd jbd2 lockd evdev sunrpc \
	    af_packet \
	    =ide =ata =ethernet =usb/storage =usb/host =nfs" \
        --filesystems "aufs squashfs vfat msdos iso9660 isofs xfs ext3 ext4 fuse nfs cifs udf nls_cp866 nls_utf8 " \
        --confdir "dracut.conf.d" \
        -i initrd / \
        --kernel-cmdline "uird.from=/MagOS,/MagOS-Data uird.ro=*.xzm,*.rom,*.rom.enc,*.pfs,*.sfs uird.rw=*.rwm,*.rwm.enc uird.cp=*.xzm.cp,*/rootcopy uird.load=/base/,/modules/ uird.machines=/MagOS-Data/machines uird.config=MagOS.ini" \
        -c dracut.conf -v -M uird.magos.cpio.xz $(uname -r)  >dracut.log 2>&1

#	    af_packet 3c59x acenic de4x5 e1000 e1000e e100 epic100 hp100 ne2k-pci pcnet32 8139too 8139cp tulip via-rhine r8169 atl1e yellowfin tg3 dl2k ns83820 atl1 b44 bnx2 skge sky2 tulip depca 3c501 3c503 3c505 3c507 3c509 3c515 ac3200 at1700 cosa cs89x0 de600 de620 e2100 eepro eexpress eth16i ewrk3 forcedeth hostess_sv11 hp-plus hp ni52 ni65 sb1000 sealevel smc-ultra sis900 smc9194  wd \

#        -c dracut.conf -v -M uird.magos.cpio.xz 3.14.17-pf4 >dracut.log 2>&1
