#!/bin/bash 
WORKDIR=$(realpath ./)
[ $1 ] && WORKDIR=$(realpath "$1")
if [ -d ${WORKDIR}/dracut ] ; then
    echo   "${WORKDIR}/dracut already exists"
    exit 1
fi
mkdir -p "${WORKDIR}/dracut/dracut.conf.d" "${WORKDIR}/dracut/modules.d"
for a in init logger functions ; do
    ln -s /usr/lib/dracut/dracut-${a}.sh ${WORKDIR}/dracut/
done
ln -s "$(which dracut)" ${WORKDIR}/dracut/dracut.sh
ln -s "$(which dracut-install)" ${WORKDIR}/dracut/dracut-install

ln -s ${WORKDIR}modules.d/* "${WORKDIR}/dracut/modules.d/"
ln -s /usr/lib/dracut/modules.d/* "${WORKDIR}/dracut/modules.d/"







 
