#!/bin/bash
# dracut 046
git submodule init
git submodule update
cd dracut
patch -N -p1 < ../0001-fix-for-shutdown-using-plymouth.patch || exit %{LINENO}
#busybox setfont не умеет без путей
#TODO шрифт должен устанавливаться с локалью 
sed -i 's:^DEFAULT_FONT=.*:DEFAULT_FONT=/usr/lib/consolefonts/ru/UniCyr_8x14.psf' /modules.d/10i18n/console_init.sh || exit %{LINENO}
make clean
./configure --disable-documentation
make -j $(( $(nproc) + 1 ))
# make install
cd ..
