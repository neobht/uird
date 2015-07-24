#!/bin/bash
./dracut/dracut.sh -l -N  -f -m ""  \
        -i "configs" /  \
        -c dracut_configs.conf -v -M uird.configs.cpio.xz $(uname -r) >dracut_configs.log 2>&1


