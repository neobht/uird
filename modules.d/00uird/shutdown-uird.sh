#!/bin/sh
nosave="no" ; shell="no" ; ask="no" ; ERROR=yes
DEFSQFSOPT="-b 512K -comp lz4"

. /oldroot/etc/initvars
. /shutdown.cfg

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
brown='\033[0;33m'
blue='\033[0;34m'
light_blue='\033[1;34m'
magenta='\033[1;35m'
cyan='\033[0;36m'
white='\033[0;37m'
purple='\033[0;35m'
default='\033[0m'
 
IMAGES=/oldroot${SYSMNT}/bundles 
egrep "$IMAGES" /proc/mounts | awk '{print $2}' | while read a ; do
   mount -t aufs -o remount,del:"$a" aufs /oldroot 
	if umount $a  ; then
		echo -e "[  ${green}OK${default}  ] Umount: $a"
	else
		echo -e "[${red}FALSE!${default}] Umount: $a"	
	fi
done
mkdir ${SYSMNT}
mount -o move /oldroot${SYSMNT}  ${SYSMNT}
#savetomodule
if 	[ $CHANGESMNT ] ; then
	SRC=${SYSMNT}/changes
	if umount /oldroot  ; then
		echo -e "[  ${green}OK${default}  ] Umount: ROOT AUFS"
	else
		echo -e "[${red}FALSE!${default}] Umount: ROOT AUFS"	
	fi
	umount $(mount | egrep -v "tmpfs|zram|proc|sysfs" | awk  '{print $3}' | sort -r)
	/remount
	. $CHANGESMNT
	. /shutdown.cfg # need to hot changed MODE in config file
	n=0
	for a in $(cat "$CHANGESMNT" |grep XZM) ; do
		eval REBUILD=\$REBUILD$n
		eval XZM=\$XZM$n
		eval MODE=\$MODE$n
		eval ADDFILTER="\$ADDFILTER$n"
		eval DROPFILTER="\$DROPFILTER$n"
		eval SQFSOPT="\$XZMOPT$n"
		n=$(expr $n + 1)
		[ "$REBUILD" != "yes"  ] && continue
		SAVETOMODULEDIR="$(dirname $CHANGESMNT)"
		if [ -w $SAVETOMODULEDIR  ] ;then
			mkdir -p /tmp
			echo -e "/tmp/includedfiles\n/tmp/excludedfiles" > /tmp/excludedfiles
			if [ -n "$ADDFILTER" -o -n "$DROPFILTER" ] ;then 
				>/tmp/savelist.black
				for item in $DROPFILTER ; do echo "$item" >> /tmp/savelist.black ; done
				>/tmp/savelist.white
				for item in $ADDFILTER ; do echo "$item" >> /tmp/savelist.white ; done
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
		fi
		sed -i 's|^/||' /tmp/excludedfiles
		[ "$shell" == "yes" ] && /bin/ash
		if [ "$ask" == "yes" ] ; then
			echo -e "${brown}The system is ready to save changes to the $SAVETOMODULENAME ${default} "
			echo -ne $yellow"(C)ontinue(default), (A)bort: $default"
			read ASK
		case "$ASK" in
			"A" | "a") REBUILD="no" ;;
			*) echo "Saving changes..." ;;
		esac
		fi
	if [ "$REBUILD" == "yes"  ] ; then
		SAVETOMODULENAME="${SAVETOMODULEDIR}/$XZM"
		[ -z "$SQFSOPT" ] && SQFSOPT="$DEFSQFSOPT"
		# if old module exists we have to concatenate it
		if [ -f "$SAVETOMODULENAME" -a "$MODE" = "mount" ]; then
			echo "Old module exists, we have to concatenate it"
			AUFS=/tmp/aufs
			mkdir -p $AUFS ${AUFS}-bundle
			mount -o loop "$SAVETOMODULENAME" ${AUFS}-bundle
			mount -t aufs -o br:$SRC=rw:${AUFS}-bundle=ro+wh aufs $AUFS 
			[ $? == 0 ] && SRC=$AUFS
		fi
		echo "Please wait. Saving changes to module ${SAVETOMODULENAME}....."
		mksquashfs $SRC "${SAVETOMODULENAME}.new" -ef /tmp/excludedfiles $SQFSOPT -progress -noappend > /dev/null
		if [ $? == 0 ] ; then
			echo -e "[  ${green}OK${default}  ]  $SAVETOMODULENAME  -- complete."
			[ -f "$SAVETOMODULENAME" ] && mv -f "$SAVETOMODULENAME" "${SAVETOMODULENAME}.bak" 
			mv -f "${SAVETOMODULENAME}.new" "$SAVETOMODULENAME" 
			chmod 444 "$SAVETOMODULENAME"
			ERROR="no"
		fi
			umount $AUFS  2> /dev/null
			umount ${AUFS}-bundle 2> /dev/null 
	fi
	if  [ "$ERROR" == "yes" ] ; then
		echo -e  "[  ${red}FALSE!${default}  ]  System changes was not saved to $SAVETOMODULENAME"
		sleep 60
	fi
	done
fi

for mntp in $(mount | egrep -v "tmpfs|proc|sysfs" | awk  '{print $3}' | sort -r) ; do
	if umount $mntp ; then 
		echo -e "[  ${green}OK${default}  ] Umount: $mntp"
	else
		"[${red}FALSE!${default}] Umount: $mntp"
		mount -o remount,ro $mntp && echo -e "[  ${green}OK${default}  ] Remount RO: $mntp"
	fi
done

echo "#####################################"
echo "##### ### ## ##     ##     ##########"
echo "##### ### ## ## ### ## #### #########"
echo "##### ### ## ## ## ### #### #########"
echo "#####     ## ## ### ##     ##########"
echo "#####################################"
grep /dev/sd /proc/mounts && exit 1
exit 0

 
