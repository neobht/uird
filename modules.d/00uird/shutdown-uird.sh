#!/bin/sh
shell="no" ; ask="no" ; silent="no" ; haltonly="no" ; lowuptime="no"
DEVNULL=''
DEFSQFSOPT="-b 512K -comp lz4"
ACTION=$(ps |grep -m1 shutdown |sed 's:.*/shutdown ::' |cut -f1 -d " ") # reboot or halt
uptime=$(( $(cut -f1 -d "." /proc/uptime) / 60 ))
[ "$uptime" -lt 3 ] && lowuptime=yes

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
black='\033[0;30m'

BALLOON_COLOR="$white"
BALLOON_SPEED='0.02'

get_MUID() {
		# calculate machine UID
		MUID=mac-$(cat /sys/class/net/e*/address 2>/dev/null | head -1 | tr -d :)
		[ "$MUID" = "mac-" ] && MUID=mac-$(cat /sys/class/net/*/address 2>/dev/null | head -1 | tr -d :)
		[ "$MUID" = "mac-" ] && MUID=vga-$(lspci -mm | grep -i vga | md5sum | cut -c 1-12)
		echo "$MUID"
	}

echolog() {
mkdir -p $SRC/var/log/
	echo "$@" 2>/dev/null >> $SRC/var/log/uird.shutdown.log
	if 	[ "$silent" == no ] >/dev/null ; then
		local key
		key="$1"
	shift
		echo -e "$key" $@ >/dev/console 2>/dev/console
	fi
}

shell_() {
	echo -e  ${red}"Please, enter \"exit\", to continue shutdown"${default}
	/bin/ash
	echo ''
}

banner() {
# $1 BALLOON_COLOR
# $2 BALLOON_SPEED
echo -e $1
t=$2
if [ $COLUMNS ] ; then
	TERMLEN=$COLUMNS
else
	TERMLEN=150
fi
for a in $(seq 50) ; do echo '' ; done
for a in "######" \
"################" \
"########################" \
"##############################" \
"##################################" \
"####################################" \
"######################################" \
"########################################" \
"########################################" \
"######################################" \
"####################################" \
"##################################" \
"############################" \
"########################" \
"####################" \
"################" \
"############" \
"####" \
"#${LIVEKITNAME}#" \
"######" \
"|" \
"|" \
"\\" \
"    \  " \
"     \ " \
"      |" \
"       \ " \
"        \\" \
"        |" ; do
	sleep $t   
	len=$(expr $(echo "$a" |wc -m) - 1)
  	printf "%*s\n" $[$(("$TERMLEN" + "$len"))/2] "$a"
  
done
for a in $(seq 70) ; do echo '' ; sleep $t; done
echo -e $black
}

rebuild() {
	BALLOON_COLOR="$green"
	echolog "Remounting media for saves..."
	echolog $(/remount 2>&1 && echo -e "[  ${green}OK${default}  ] Remount complete")
	CFGPWD=$(dirname $CHANGESMNT)
	export CFGPWD # maybe it is not necessary
	if [ -f $CHANGESMNT ] ; then
		. $CHANGESMNT
	else
		echolog "ERROR: $CHANGESMNT no such file!"
		BALLOON_COLOR="$red" 
		BALLOON_SPEED="0.05"
		sleep 10
		return
	fi
	. /shutdown.cfg # this is necessary to hot change the mode
	# number of enumerated sections
	end=$(( $(cat "$CHANGESMNT" |egrep '^[[:space:]]*XZM[[:digit:]]{,2}=' |wc -l) - 1 ))
	# list of not enumerated sections
	notenumerated=$(cat "$CHANGESMNT" |egrep '^[[:space:]]*XZM.*[a-zA-Z]+.*=' |sed -e 's/^[[:space:]]*XZM//' -e 's/=.*$//')
	for n in $(seq 0 $end) $notenumerated; do
		SRC=${SYSMNT}/changes
		eval REBUILD=\$REBUILD$n
		eval XZM=\$XZM$n
		[ -z "$XZM" ] && XZM=$(get_MUID).xzm
		eval MODE=\$MODE$n
		eval ADDFILTER="\$ADDFILTER$n"
		eval DROPFILTER="\$DROPFILTER$n"
		eval SQFSOPT="\$XZMOPT$n"
		[ "$REBUILD" != "yes"  ] && continue
		SAVETOMODULEDIR="$(dirname $CHANGESMNT)"
		[ -w $SAVETOMODULEDIR  ] || continue
		[ "$shell" == "yes" ] && shell_
		if [ "$ask" == "yes" -o "$lowuptime" == "yes" ] ; then
			echolog "Uptime: $uptime min"
			echo -e "${brown}The system is ready to save changes to the $XZM ${default} "
			echo -ne $yellow"(C)ontinue(default), (A)bort: $default"
			read ASK
		case "$ASK" in
			"A" | "a") REBUILD="no" ;;
			*) echolog "Saving changes..." ;;
		esac
		fi
	if [ "$REBUILD" == "yes"  ] ; then
		SAVETOMODULENAME="${SAVETOMODULEDIR}/$XZM"
		[ -z "$SQFSOPT" ] && SQFSOPT="$DEFSQFSOPT"
		# if old module exists we have to concatenate it
		if [ -f "$SAVETOMODULENAME" -a "$MODE" = "mount" ]; then
			echolog "Old module exists, we have to concatenate it"
			AUFS=/tmp/aufs
			mkdir -p $AUFS ${AUFS}-bundle
			mount -o loop "$SAVETOMODULENAME" ${AUFS}-bundle
			mount -t aufs -o br:$SRC=rw:${AUFS}-bundle=ro+wh aufs $AUFS 
			[ $? == 0 ] && SRC=$AUFS
		fi
			mkdir -p /tmp
			#cut aufs arefacts
			echo "/.wh..*" > /tmp/excludedfiles
			#cut garbage 
			echo "/.cache" >> /tmp/excludedfiles
			echo "/.dbus" >> /tmp/excludedfiles
			echo "/run" >> /tmp/excludedfiles
			echo "/tmp" >> /tmp/excludedfiles
			echo "/memory" >> /tmp/excludedfiles
			echo "/dev" >> /tmp/excludedfiles # maybe it is not necessary
			echo "/proc" >> /tmp/excludedfiles # maybe it is not necessary
			echo "/sys" >> /tmp/excludedfiles # maybe it is not necessary
			if [ -n "$ADDFILTER" -o -n "$DROPFILTER" ] ;then
				echolog "Please wait. Preparing excludes for module ${SAVETOMODULENAME}....." 
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
			fi
		sed -i 's|^/||' /tmp/excludedfiles
		echolog "Please wait. Saving changes to module ${SAVETOMODULENAME}....."
		[ "$shell" = "yes" ] && shell_
		eval mksquashfs $SRC "${SAVETOMODULENAME}.new" -ef /tmp/excludedfiles $SQFSOPT -wildcards $DEVNULL 
		if [ $? == 0 ] ; then
			echolog "[  ${green}OK${default}  ]  $SAVETOMODULENAME  -- complete."
			[ -f "$SAVETOMODULENAME" ] && mv -f "$SAVETOMODULENAME" "${SAVETOMODULENAME}.bak" 
			mv -f "${SAVETOMODULENAME}.new" "$SAVETOMODULENAME" 
			chmod 444 "$SAVETOMODULENAME"
		else
			BALLOON_COLOR="$red" 
			BALLOON_SPEED="0.05"
			echo -e "[  ${red}FALSE!${default}  ]  System changes was not saved to $SAVETOMODULENAME"
			echo "          Changes dir is $SRC, you may try to save it manualy"
			shell_
		fi
			umount $AUFS  2> /dev/null
			umount ${AUFS}-bundle 2> /dev/null 
	fi
	done
}

[ -f /oldroot/etc/initvars ] && . /oldroot/etc/initvars || BALLOON_COLOR="$red"
[ -f /shutdown.cfg ] && . /shutdown.cfg || BALLOON_COLOR="$red"
if ! [ -d "/oldroot$SYSMNT" ] ; then
	echolog "ERROR:  /oldroot$SYSMNT no such directory"
	BALLOON_COLOR="$red"
	unset CHANGESMNT
	sleep 5
fi 
[ "$silent" = "yes" ] && DEVNULL=">/dev/null" 
 
SRC=/oldroot${SYSMNT}/changes
mkdir -p $SRC/var/log/
echo "UIRD shutdown started!" > $SRC/var/log/uird.shutdown.log 
 
#umount bundles
IMAGES=/oldroot${SYSMNT}/bundles 
egrep "$IMAGES" /proc/mounts | awk '{print $2}' | while read a ; do
    mount -t aufs -o remount,del:"$a" aufs /oldroot
	if umount $a  ; then
		echolog "[  ${green}OK${default}  ] Umount: $a"
	else
		echolog "[${red}FALSE!${default}] Umount: $a"	
	fi
done
mkdir -p ${SYSMNT}
mount -o move /oldroot${SYSMNT}  ${SYSMNT} 
[ "$ACTION" = "reboot" -a "$haltonly" = "yes" ] && unset CHANGESMNT  
if umount /oldroot  ; then
	echolog "[  ${green}OK${default}  ] Umount: ROOT AUFS"
else
	echolog "[${red}FALSE!${default}] Umount: ROOT AUFS"	
fi
echolog $(umount $(mount | egrep -v "tmpfs|zram|proc|sysfs" | awk  '{print $3}' | sort -r) 2>&1)

#save changes to modules
[ $CHANGESMNT ] && rebuild

for mntp in $(mount | egrep -v "tmpfs|proc|sysfs" | awk  '{print $3}' | sort -r) ; do
	if umount $mntp ; then 
		echolog "[  ${green}OK${default}  ] Umount: $mntp"
	else
		echo -e "[${red}FALSE!${default}] Umount: $mntp"
		mount -o remount,ro $mntp && echolog "[  ${green}OK${default}  ] Remount RO: $mntp"
	fi
done
[ "$shell" = "yes" ] && shell_
[ "$silent" = "no" ] && banner "$BALLOON_COLOR" "$BALLOON_SPEED"
grep -q /dev/sd /proc/mounts && exit 1
exit 0

 
