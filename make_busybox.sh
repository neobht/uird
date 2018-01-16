#!/bin/bash
git submodule init
git submodule update
cd busybox
make defconfig
make 
# make install
cd ..
