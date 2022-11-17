#!/bin/bash
# dracut 046
git submodule init
git submodule update
cd dracut
patch -N -p1 < ../0001-do_not_kill_plymouth.patch
make clean
./configure --disable-documentation
make -j $(( $(nproc) + 1 ))
# make install
cd ..
