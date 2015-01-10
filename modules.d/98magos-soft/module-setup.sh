#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
    return 0
}

depends() {
    # We depend on magos modules being loaded
#    echo magos
    return 0
}


install() {
    #mc
    dracut_install /usr/bin/mc /usr/bin/mcview /usr/bin/mcedit /usr/bin/mcdiff
    dracut_install /usr/share/mc/*
    dracut_install /usr/share/mc/examples/macros.d/*
    dracut_install /usr/share/mc/help/*
    dracut_install /usr/share/mc/skins/*
    dracut_install /usr/share/mc/syntax/*
    
    #netfs
#    dracut_install "$(type -p httpfs)"
#    dracut_install "$(type -p sshfs)"
#    dracut_install "$(type -p curlftpfs)"
}

