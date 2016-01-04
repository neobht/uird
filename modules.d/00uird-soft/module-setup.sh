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
    dracut_install /usr/share/mc/hints/*
    dracut_install /usr/share/mc/skins/*
    dracut_install /usr/share/mc/syntax/*
    dracut_install /usr/share/locale/LC_MESSAGES/ru/mc.mo
    dracut_install /usr/share/locale/ru/LC_MESSAGES/mc.mo
    dracut_install /etc/mc/*
    dracut_install /etc/profile.d/mc.sh
    dracut_install /usr/lib64/mc/*
    dracut_install /usr/lib64/mc/ext.d/*
    dracut_install /usr/lib64/mc/extfs.d/*
    dracut_install /usr/lib64/mc/fish/*
    dracut_install /usr/lib/mc/*
    dracut_install /usr/lib/mc/ext.d/*
    dracut_install /usr/lib/mc/extfs.d/*
    dracut_install /usr/lib/mc/fish/*

#    dracut_install /usr/bin/mplayer    

    dracut_install /usr/bin/ssh

#    inst /usr/bin/git
#    inst_multiple \
#		/usr/lib64/git-core/git-sh-i18n \
#		/usr/lib64/git-core/git-sh-i18n--envsubst \
#		/usr/lib64/git-core/git-sh-setup \
#		/usr/lib64/git-core/git-http-backend \
#		/usr/lib64/git-core/git-http-fetch \
#		/usr/lib64/git-core/git-http-push \
#		/usr/lib64/git-core/git-stash \
#		/usr/lib64/git-core/git-remote-https \
#		/usr/lib64/git-core/git-svn \
#		/usr/lib64/git-core/git-submodule \
#		/usr/lib64/git-core/git-parse-remote \ 
#		/usr/lib64/git-core/git-rebase \
#		/usr/lib64/git-core/git-rebase--am \
#		/usr/lib64/git-core/git-rebase--interactive \
#		/usr/lib64/git-core/git-rebase--merge
#    inst_libdir_file /usr/lib64/git-core/*
#	cc
    inst cc    
}

