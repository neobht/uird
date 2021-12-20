#!/bin/bash
git submodule init
git submodule update
cd busybox
make -j $(( $(nproc) + 1 )) defconfig
make
# make install
cd ..
