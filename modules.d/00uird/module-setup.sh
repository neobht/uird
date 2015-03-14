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
    return 0
}

install() {
    local _i _progs _path _busybox _binaries
    #uird 
    inst "$moddir/livekit/livekitlib" "/livekitlib"
    inst "$moddir/livekit/uird-init" "/uird-init"
    inst "$moddir/livekit/liblinuxlive" "/liblinuxlive"

    #binaries
    inst $(type -p bash) /bin/bash
    inst $(type -p blkid) /sbin/blkid.real
    inst $(type -p losetup) /sbin/losetup.real

    _binaries="dialog gettext loadkeys resume rsync fsck fsck.ext2 fsck.ext3 fsck.ext4 fsck.exfat fsck.vfat fsck.xfs fsck.btrfs btrfsck ntfsfix"
    for _i in $_binaries; do
	inst $(type -P "$_i" ) /sbin/$_i
    done
    #busybox
    _busybox=$(type -P busybox || type -P busybox.static )
    inst $_busybox /usr/bin/busybox
    for _i in $($_busybox --list)
    do
        _progs="$_progs $_i"
    done

    for _i in $_progs; do
        _path=$(find_binary "$_i")
        [ -z "$_path" ] && _path=/bin/$_i
	[[ -x $initdir/$_path ]] && continue

        ln_r /usr/bin/busybox $_path
    done

    
#    inst $(type -p dialog) /sbin/dialog
#    inst $(type -p gettext) /sbin/gettext
#    inst $(type -p loadkeys) /sbin/loadkeys
#    inst $(type -p resume) /sbin/resume
#    inst $(type -p rsync) /sbin/rsync
    
#    inst $(type -p fsck) /sbin/fsck
#    inst $(type -p fsck.ext2) /sbin/fsck.ext2
#    inst $(type -p fsck.ext3) /sbin/fsck.ext3
#    inst $(type -p fsck.ext4) /sbin/fsck.ext4
#    inst $(type -p fsck.exfat) /sbin/fsck.exfat
#    inst $(type -p fsck.vfat) /sbin/fsck.vfat
#    inst $(type -p fsck.xfs) /sbin/fsck.xfs
#    inst $(type -p fsck.btrfs) /sbin/fsck.btrfs
#    inst $(type -p btrfsck) /sbin/btrfsck
#    inst $(type -p ntfsfix) /sbin/ntfsfix
#    inst $(type -p mount.cifs) /sbin/mount.cifs
#    inst $(type -p mount.nfs) /sbin/mount.nfs
    
    inst_hook cmdline 95 "$moddir/parse-root-uird.sh"
    inst_hook mount 99 "$moddir/mount-uird.sh"
#    inst_hook shutdown 99 "$moddir/shutdown-uird.sh"
}

