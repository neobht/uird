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
    inst "$moddir/bash-$(uname -i)" "/bin/bash"
    [ -x "$initdir/bin/bash" ] || inst $(type -p bash) "/bin/bash"
    inst $(type -p blkid) /sbin/blkid.real
    inst $(type -p losetup) /sbin/losetup.real

    _binaries="locale dialog gettext loadkeys resume rsync fsck fsck.ext2 fsck.ext3 fsck.ext4 fsck.exfat fsck.vfat fsck.xfs fsck.btrfs btrfsck ntfsfix"
    for _i in $_binaries; do
	inst $(type -p "$_i" ) /sbin/$_i
    done
    #busybox
    _busybox=$(type -p busybox || type -p busybox.static )
    inst $_busybox /usr/bin/busybox
    _progs=""
    for _i in $($_busybox --list)
    do
        _progs="$_progs $_i"
    done

    for _i in $_progs; do
        _path=$(find_binary "$_i")
        [ -z "$_path" ] && _path=/bin/$_i
	[[ -x $initdir/$_path ]] && continue
        ln_r /usr/bin/busybox "$_path"
    done

#    echo "version: $(date +%Y%m%d), for kernel: $(uname -ri)" >$initdir/uird_version
    echo "version: $(date +%Y%m%d), for kernel: $kernel" >$initdir/uird_version
    inst_hook cmdline 95 "$moddir/parse-root-uird.sh"
    inst_hook mount 99 "$moddir/mount-uird.sh"
#    inst_hook shutdown 99 "$moddir/shutdown-uird.sh"
}

