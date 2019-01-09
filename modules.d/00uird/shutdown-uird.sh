#!/bin/sh
. /oldroot/etc/initvars 
IMAGES=/oldroot${SYSMNT}/bundles 
egrep "$IMAGES" /proc/mounts | awk '{print $2}' | while read a ; do
   mount -t aufs -o remount,del:"$a" aufs /oldroot 
   umount $a  && echo "Umount: $a -- OK"
done
mkdir ${SYSMNT}
mount -o move /oldroot${SYSMNT}  ${SYSMNT}

#savetomodule
if [ -f ${SYSMNT}/changes/.savetomodule -a -x /remount ] ; then
	SAVETOMODULEOPTIONS="-comp lz4"
	SRC=${SYSMNT}/changes
	FILELIST=${SYSMNT}/changes/.savelist
	touch /oldroot/.savelist
	touch /oldroot/.savetomodule
	umount /oldroot
	umount $(mount | egrep -v "tmpfs|zram|proc|sysfs" | awk  '{print $3}' | sort -r)
	/remount
	SAVETOMODULENAME="$(cat ${SYSMNT}/changes/.savetomodule)"
	# if machine was freezed
	egrep -q '/dynamic/|/static/' ${SYSMNT}/changes/.savetomodule 2>/dev/null  && [ -f "$(sed s=dynamic=static= ${SYSMNT}/changes/.savetomodule)" ] && SAVETOMODULE=no
	# if machine was unfreezed
	grep -q /static/ ${SYSMNT}/changes/.savetomodule 2>/dev/null && [ ! -f "$(cat ${SYSMNT}/changes/.savetomodule)" ] && SAVETOMODULENAME=$(sed s=static=dynamic= ${SYSMNT}/changes/.savetomodule)
	SAVETOMODULEDIR="$(dirname $SAVETOMODULENAME)"
	if [ -w $SAVETOMODULEDIR  ] ;then
		echo "Please wait. Saving changes to module $SAVETOMODULENAME"
		mkdir -p /tmp
		echo -e "/tmp/includedfiles\n/tmp/excludedfiles" > /tmp/excludedfiles
		if [ -f "$FILELIST" ] ;then
			grep ^! "$FILELIST" | cut -c 2- >/tmp/savelist.black
			grep -v '^[!#]' "$FILELIST" | grep . >/tmp/savelist.white
			grep -q . /tmp/savelist.white || echo '.' > /tmp/savelist.white
			find $SRC/ -type l >/tmp/allfiles
			find $SRC/ -type f >>/tmp/allfiles
			sed -i 's|'$SRC'||' /tmp/allfiles
			grep -f /tmp/savelist.white /tmp/allfiles | grep -vf /tmp/savelist.black > /tmp/includedfiles
			grep -q . /tmp/savelist.black && grep -f /tmp/savelist.black /tmp/allfiles >> /tmp/excludedfiles
			grep -vf /tmp/savelist.white /tmp/allfiles >> /tmp/excludedfiles
			find $SRC/ -type d | sed 's|'$SRC'||' | while read a ;do
				grep -q "^$a" /tmp/includedfiles && continue
				echo "$a" | grep -vf /tmp/savelist.black | grep -qf /tmp/savelist.white && continue
				echo "$a" >> /tmp/excludedfiles
			done
			rm -f /tmp/savelist* /tmp/allfiles /tmp/includedfiles
		fi
		sed -i 's|^/||' /tmp/excludedfiles
		# backuping old module
		[ -f "$SAVETOMODULENAME" ] && mv -f "$SAVETOMODULENAME" "${SAVETOMODULENAME}.bak"
		# making module
		mksquashfs $SRC "$SAVETOMODULENAME" -ef /tmp/excludedfiles $SAVETOMODULEOPTIONS -noappend
		chmod 444 "$SAVETOMODULENAME"
	fi
fi
for mntp in $(mount | egrep -v "tmpfs|proc|sysfs" | awk  '{print $3}' | sort -r) ; do
umount $mntp || mount -o remount,ro $mntp
done 

echo "#####################################"
echo "##### ### ## ##     ##     ##########"
echo "##### ### ## ## ### ## #### #########"
echo "##### ### ## ## ## ### #### #########"
echo "#####     ## ## ### ##     ##########"
echo "#####################################"
sleep 1
exit 0 

 
