#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
    return 0
}

depends() {
    # We depend on modules being loaded
    return 0
}

installkernel() {
    #install network modules
#    instmods af_packet 3c59x acenic de4x5 e1000 e1000e e100 epic100 hp100 \
#	    ne2k-pci pcnet32 8139too 8139cp tulip via-rhine r8169 atl1e yellowfin \
#	    tg3 dl2k ns83820 atl1 b44 bnx2 skge sky2 tulip depca 3c501 3c503 \
#	    3c505 3c507 3c509 3c515 ac3200 at1700 cosa cs89x0 de600 de620 e2100 \
#	    eepro eexpress eth16i ewrk3 forcedeth hostess_sv11 hp-plus hp ni52 \
#	    ni65 sb1000 sealevel smc-ultra sis900 smc9194 wd
    
#    instmods nls_cp866 nls_utf8 nfs nfs_acl jbd jbd2 lockd

    return 0
#    instmods aes-i586 aes_generic cbc loop cryptoloop zlib_deflate crc-t10dif crc16 \
#             dca hid usbhid libphy mii virtio_net pcmcia pcmcia_core yenta_socket \
#             scsi_mod sd_mod sr_mod vmw_pvscsi usb-common usbcore ehci-hcd uhci-hcd ohci-hcd \
#             uas ums-datafab ums-isd200 ums-onetouch ums-sddr55 ums-alauda ums-eneub6250 ums-jumpshot \
#             ums-realtek ums-usbat ums-cypress ums-freecom ums-karma ums-sddr09 usb-storage \
#             acard-ahci pata_arasan_cf pata_cypress pata_legacy pata_pcmcia pata_sil680 sata_qstor \
#             ahci pata_artop pata_efar pata_marvell pata_pdc2027x pata_sis sata_sil24 \
#             ahci_platform pata_atiixp pata_hpt366 pata_mpiix pata_pdc202xx_old pata_sl82c105 sata_sil \
#             ata_generic pata_atp867x pata_hpt37x pata_netcell pata_piccolo pata_triflex sata_sis \
#             ata_piix pata_cmd640 pata_hpt3x2n pata_ninja32 pata_radisys pata_via sata_svw \
#             libahci pata_cmd64x pata_hpt3x3 pata_ns87410 pata_rdc pdc_adma sata_sx4 \
#             libata pata_cs5520 pata_isapnp pata_ns87415 pata_rz1000 sata_inic162x sata_uli \
#             pata_acpi pata_cs5530 pata_it8213 pata_oldpiix pata_sc1200 sata_mv sata_via \
#             pata_ali pata_cs5535 pata_it821x pata_optidma pata_sch sata_nv sata_vsc \
#             pata_amd pata_cs5536 pata_jmicron pata_opti pata_serverworks sata_promise scsi_wait_scan crc-itu-t
#    instmods aufs squashfs ext3 ext4 fat msdos vfat btrfs fscache fuse isofs jbd jbd2 lockd nfs_acl ntfs reiserfs xfs nfs nls_cp866 nls_utf8
}

install() {
    #uird 
    inst "$moddir/livekit/livekitlib" "/livekitlib"
    inst "$moddir/livekit/uird-init" "/uird-init"
    inst "$moddir/livekit/liblinuxlive" "/liblinuxlive"
    
    inst $(type -p bash) /bin/bash
    inst $(type -p busybox.static) /usr/bin/busybox
    ln_r /usr/bin/busybox /bin/sh
    inst $(type -p dialog) /sbin/dialog
    inst $(type -p blkid) /sbin/blkid.real
    inst $(type -p losetup) /sbin/losetup.real
    inst $(type -p gettext) /sbin/gettext
    inst $(type -p loadkeys) /sbin/loadkeys
    inst $(type -p resume) /sbin/resume
    inst $(type -p rsync) /sbin/rsync
    
    inst $(type -p fsck) /sbin/fsck
    inst $(type -p fsck.ext2) /sbin/fsck.ext2
    inst $(type -p fsck.ext3) /sbin/fsck.ext3
    inst $(type -p fsck.ext4) /sbin/fsck.ext4
    inst $(type -p fsck.exfat) /sbin/fsck.exfat
    inst $(type -p fsck.vfat) /sbin/fsck.vfat
    inst $(type -p fsck.xfs) /sbin/fsck.xfs
    inst $(type -p fsck.btrfs) /sbin/fsck.btrfs
    inst $(type -p ntfsfix) /sbin/ntfsfix
    
    inst_hook cmdline 95 "$moddir/parse-root-uird.sh"
    inst_hook mount 99 "$moddir/mount-uird.sh"
#    inst_hook shutdown 99 "$moddir/shutdown-uird.sh"
}

