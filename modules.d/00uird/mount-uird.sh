#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh
#

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh


if ! getargbool 0 nouird; then
    mount_root() {
	. /uird-init
    }
    mount_root
fi
