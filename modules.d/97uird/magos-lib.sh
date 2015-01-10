#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

# magos_to_var MAGOSROOT
# use MAGOSROOT to set $from, $data, and $options.
# MAGOSROOT is something like: magos:<base_from>:<data_from>[,<options>]

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

magos_to_var() {
	local params

	params=${1##magos:}
	params=${params%%,*}
	base_from=${params%%:*}
	data_from=${params##*:}

	magosoptions=${1#*,}
}

# =================================================================
# debug and output functions
# =================================================================

# update given line in fstab, add new values only if the device is not found
# $1 = fstab file to parse
# $2 = device name
# $3 = mountpoint
# $4 = filesystem
# $5 = mount options
#
fstab_add_line()
{
 [ "$3" != "none" ] && grep -q " $3 " $1 && return 0
 echo "$2" "$DIR" "$4" "$5" 0 0 "# AutoUpdate" >>$1
}


# Check boot parameter
# $1 mountpoint
 umountloop()
{
 LOOPDEVICE=$(grep "/dev/loop.* $1 " /proc/mounts | awk '{print $1}')
 umount $1 || return 1
 [ -z "$LOOPDEVICE" ] || losetup -d $LOOPDEVICE
}

# Check boot parameter
# $1 - parameter's name
# stdout - $1 if found
 cmdline_parameter()
{
 ADDFILE=/tmp/cmdline
 [ -f /mnt/live/$ADDFILE ] && ADDFILE=/mnt/live$ADDFILE
 cat /proc/cmdline $ADDFILE 2>/dev/null | egrep -m1 -o "(^|[[:space:]])$1([[:space:]]|\$)" | tr -d " "
}

# Get boot parameter value
# $1 - parameter's name
# stdout - parameter's value
 cmdline_value()
{
 ADDFILE=/tmp/cmdline
 [ -f /mnt/live/$ADDFILE ] && ADDFILE=/mnt/live$ADDFILE
 cat /proc/cmdline $ADDFILE 2>/dev/null | egrep -m1 -o "(^|[[:space:]])$1=[^[:space:]]+" | cut -d "=" -f 2-
}


# Make from ini file text file with strings like [SECTION]Name=Value
# $1 - input filename
# stdout - result file
 ini2simple()
{
 SECTION='[]'
 cat $1 | while read a ;do
  [ "$a" = "" ] && continue
  if [ "${a#\[*\]}" = "" -a "$a" != "" ] ;then
     SECTION=$a
  else
     echo "$SECTION$a"
  fi
 done
}

# Restore ini file from text file with strings like [SECTION]Name=Value
# $1 - input filename
# stdout - result file
 simple2ini()
{
 LASTSECTION='[]'
 cat $1 | while read a ;do
  SECTION=${a%%\]*}']'
  if [ "$SECTION" != "$LASTSECTION" ] ;then
     [ "LASTSECTION" != "[]" ] && echo
     echo "$SECTION"
     LASTSECTION=$SECTION
  fi
  echo ${a#\[*\]}
 done
}

# It include string from $2 file and apply to $1 file
# $1 - base file
# $2 - included file
 apply2simple()
{
 cat "$2" | while read a ;do
  SECTION=${a%%\]*}
  SECTION=${SECTION#\[}
  STR=${a#\[*\]}
  PNAME=${STR%%=*}
  PVAL=${a#*=}
#  echo $SECTION $PNAME $PVAL
  echo -ne >"$1.tmp"
  echo -ne >"$1.lck"
  FOUNDS=
  cat "$1" | while read b ;do
     BSECTION=${b%%\]*}
     BSECTION=${BSECTION#\[}
     BSTR=${b#\[*\]}
     BPNAME=${BSTR%%=*}
     BPVAL=${b#*=}
     
     [ "$BSECTION" = "$SECTION" ] && FOUNDS=1
     if [ "$BSECTION" = "$SECTION" -a "$BPNAME" = "$PNAME" ] ;then
        b="$a"
        rm -f "$1.lck"
     fi
     if [ "$BSECTION" != "$SECTION" -a "$FOUNDS" != "" -a -f "$1.lck" ] ;then
        echo "$a"  >> "$1.tmp"
        rm -f "$1.lck"
     fi
     echo "$b" >> "$1.tmp"
  done
  [ -f "$1.lck" ] && echo "$a" >> "$1.tmp"
  mv -f "$1.tmp" "$1"
  rm -f "$1.lck"
 done
}

# It include string from $2 ini file and apply to $1 ini file
# $1 - base file
# $2 - included file
 concatenate_ini()
{
 [ -f "$1" -a -f "$2" ] || exit 1
 ini2simple "$1" >"$1.tmp"
 ini2simple "$2" >"$2.tmp"
 apply2simple "$1.tmp" "$2.tmp"
 simple2ini "$1.tmp" >"$1"
 rm -f "$1.tmp" "$2.tmp"
}

detectDE()
{
    if [ x"$KDE_FULL_SESSION" = x"true" ]; then echo kde
    elif [ x"$GNOME_DESKTOP_SESSION_ID" != x"" ]; then echo gnome
    elif [ x"$DESKTOP_SESSION" = x"LXDE" ]; then echo lxde
    elif ps -A | grep -q "kdeinit4" ; then echo kde
    elif ps -A | grep -q "gnome-panel" ; then echo gnome
    else echo lxde
    fi
}

# Mount device $1 to $2
# If the device is using vfat or ntfs filesystem, use iocharset as a mount option
# $1 = /dev device to mount, eg. /dev/hda1, or loop file, or directory
# $2 = mountpoint, eg. /mnt/hda1
# $3 = optional mount options, for example "ro", or "remount,rw"
# $4 = optional filesystem name, in order to skip autodetection
#
mount_device()
{
   debug_log "mount_device" "$*"
   local FS DEV LOOPDEV OPTIONS FILESYSTEM ERR

   # make sure we have enough arguments
   if [ "$2" = "" ]; then return 1; fi
   if [ "$1" = "" ]; then rmdir "$2" 2>/dev/null; return 1; fi
   # skipping MBR
   echo $(basename $1) | grep -q [a-z]$ && grep -q $(basename $1)[0-9] /proc/partitions  && return 1

   mkdir -p "$2"

   DEV="$1"
   if [ "$4" != "" ]; then FS="$4"; else FS=$(device_filesystem "$1"); fi
   if [ "$FS" ]; then OPTIONS=$(fs_options $FS mount); FS="-t $FS"; fi
   if [ "$OPTIONS" ]; then OPTIONS="$OPTIONS"; else OPTIONS=""; fi
   if [ -f "$DEV" ]; then OPTIONS="$OPTIONS,loop"; fi
   if [ -d "$DEV" ]; then OPTIONS="$OPTIONS,rbind"; fi
   if [ "$3" ]; then OPTIONS="$OPTIONS,$3"; fi
   OPTIONS=$(echo "$OPTIONS" | sed -r "s/^,+//")

   if [ "$FS" = "-t ntfs-3g" ]; then
      [ $(cmdline_parameter fsck) ] && fsck_device "$DEV" ntfs
      ntfsmount "$DEV" "$2" -o $OPTIONS >/dev/null 2>&1
      ERR=$?
   else
      [ $(cmdline_parameter fsck) ] && fsck_device "$DEV" $(echo $FS| sed "s/-t //" )
      mount -n -o $OPTIONS $FS "$DEV" "$2" >/dev/null 2>&1
      ERR=$?
   fi

   if [ $ERR -ne 0 ] && [ -f "$DEV" ] && echo "$DEV" | grep -q .enc$ ; then
       LOOPDEV=$(losetup -f)
       [ -z "$LOOPDEV" ] && LOOPDEV=$(mknod_next_loop_dev)
       OPTIONS=$(echo "$OPTIONS" | sed -r "s/,loop//g")
       echolog "Mounting encrypted filesystem $DEV" >/dev/console 2>/dev/console
       times=3
       while [ $times -gt 0 ]; do
          /usr/bin/losetup.real -e AES256 "$LOOPDEV" "$DEV" >/dev/console </dev/console 2>/dev/console
          [ $(cmdline_parameter fsck) ] && fsck_device "$LOOPDEV"
          mount -n -o $OPTIONS "$LOOPDEV" "$2" >/dev/null 2>&1
          ERR=$?
          [ $ERR -eq 0 ] && break
          /usr/bin/losetup.real -d "$LOOPDEV"
          times=$(expr $times - 1)
       done
   fi

   # not enough loop devices? try to create one.
   if [ $ERR -eq 2 ]; then
       LOOPDEV=$(mknod_next_loop_dev)
       OPTIONS=$(echo "$OPTIONS" | sed -r "s/,loop//g")
       losetup "$LOOPDEV" "$DEV" 2>/dev/null # busybox's losetup doesn't support -r
       if [ $? -ne 0 ]; then
          losetup -r "$LOOPDEV" "$DEV" 2>/dev/null # force read-only in case of error
       fi
       mount -n -o $OPTIONS $FS "$LOOPDEV" "$2" >/dev/null 2>&1
       ERR=$?
   fi

   # if nothing works, try to force read-only mount
   if [ $ERR -ne 0 ]; then
       mount -n -r -o $OPTIONS $FS "$DEV" "$2" >/dev/null 2>&1
       ERR=$?
   fi

   if [ $ERR -ne 0 ]; then rmdir $2 2>/dev/null; fi
   return $ERR
}

# Start udhcpc to get IP address from DHCP server
# $1 = interface to use (optional)
#
init_dhcp()
{
   debug_log "start_dhcp_client" "$*"
   modprobe af_packet 2>/dev/null
   if [ "$1" != "" ]; then
      ifconfig $1 up
      udhcpc -i $1 -q
   else
      ifconfig eth0 up
      udhcpc -q
   fi
}

# Mount http filesystem from the given server
# $1 = server
# $2 = mountdir
#
mount_httpfs()
{
   debug_log "mount_httpfs" "$*"

   mkdir -p $2
   /bin/httpfs $1 $2 || return
   if [ -f $2/$(basename $1) ] ;then
      echo $2/$(basename $1)
   else
      echo $2
   fi
}

# Mount curlftpfs filesystem from the given server
# $1 = server
# $2 = mountdir
#
mount_curlftpfs()
{
   local OPTIONS
   debug_log "mount_curlftpfs" "$*"
   OPTIONS=
   [ "$(cmdline_value netfsoptions)" ] && OPTIONS="-o $(cmdline_value netfsoptions)"

   mkdir -p $2
   /usr/bin/curlftpfs $OPTIONS $1 $2 </dev/console >/dev/console 2>/dev/console || return
   if [ -f $2/$(basename $1) ] ;then
      echo $2/$(basename $1)
   else
      echo $2
   fi
}

# Mount sshfs filesystem from the given server
# $1 = server
# $2 = mountdir
#
mount_sshfs()
{
   local OPTIONS
   debug_log "mount_sshfs" "$*"
   OPTIONS=
   [ "$(cmdline_value netfsoptions)" ] && OPTIONS="-o $(cmdline_value netfsoptions)"
   mkdir -p $2
   times=3
   while [ $times -gt 0 ]; do
     /usr/bin/sshfs ${1/ssh:??/} $2 $OPTIONS </dev/console >/dev/console 2>/dev/console
     ERR=$?
     [ $ERR -eq 0 ] && break
     times=$(expr $times - 1)
   done
   [ $ERR -eq 0 ] || return
   if [ -f $2/$(basename $1) ] ;then
      echo $2/$(basename $1)
   else
      echo $2
   fi
}

# Mount nfs filesystem from the given server
# $1 = server
# $2 = mountdir
#
mount_nfs()
{
   debug_log "mount_nfs" "$*"
   mkdir -p $2
   modprobe nfs
   local SHARE=`echo $1 | sed s-^nfs://-- `
   if mount -t nfs $SHARE $2 -o nolock,rsize=4096,wsize=4096 2>/dev/null ;then
      echo $2
   elif mount -t nfs $(dirname $SHARE) $2 -o nolock,rsize=4096,wsize=4096 2>/dev/null ;then
      echo $2/$(basename $SHARE)
   fi
}
