#!/bin/bash

depends() {
    echo uird-network
    return 255
}

install() {
    inst "$moddir/mount_webdav" "/mount_webdav"
    inst_multiple  mount.davfs
}

installkernel() {
    hostonly='' instmods fuse
}
