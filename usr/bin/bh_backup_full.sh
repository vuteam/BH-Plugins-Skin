#!/bin/sh
#Powered By RAED For BlackHole OE2.0 Images To Dreambox 18-10-2014
#Updated 12-12-2014
####################################################################
VSNDMAN=$4 
DIRECTORY=$1
for sig in 0 1 2 3 6 14 15; do
	trap "cleanup $sig" $sig
done

#echo "$1 $2 $3 $4"
cleanup() {
	EXIT_CODE=$?
	if [ $EXIT_CODE = 130 ] ; then
		echo "**************************"
		echo "*     Aborted by User    *"
		echo "**************************"	  
	fi

	umount $MOUNTPOINT/bi/boot  2> /dev/null
	umount $MOUNTPOINT/bi/root  2> /dev/null 
 
    rm -rf $DIRECTORY/boot.img > /dev/null 2>&1
    rm -rf $DIRECTORY/boot.ubi > /dev/null 2>&1
    rm -rf $DIRECTORY/root.img > /dev/null 2>&1
    rm -rf $DIRECTORY/root.ubi > /dev/null 2>&1
	rm -rf $DIRECTORY/secondstage.bin > /dev/null 2>&1
	swapoff $DIRECTORY/swapfile_backup > /dev/null 2>&1
	rm -rf $DIRECTORY/swapfile_backup > /dev/null 2>&1

	echo " "
	echo "exit "$EXIT_CODE
	trap - 0
	exit $EXIT_CODE
}

if [ -e /dev/mtdblock2 ]; then
	MTDBOOT=/dev/mtdblock2
	MTDROOT=/dev/mtdblock3
elif [ -e /dev/mtdblock/2 ]; then
	MTDBOOT=/dev/mtdblock/2
	MTDROOT=/dev/mtdblock/3
else
	echo "No mtdblocks found"
	exit 1 > /dev/null 2>&1
fi

if [ -e /dev/mtd/1 ]; then
   $Nanddump --noecc --omitoob --bb=skipbad --truncate --file /dev/null /dev/mtd/1 > /tmp/.raedtmp 2>&1
else
   $Nanddump --noecc --omitoob --bb=skipbad --truncate --file /dev/null /dev/mtd1 > /tmp/.raedtmp 2>&1
fi
RAEDTMP=/tmp/.raedtmp
HEADER=`head -n 1 $RAEDTMP`
BLOCKSIZE=`echo $HEADER | cut -d"," -f 2 | cut -d" " -f 4`

OPTIONS=" -e 0x4000 -n -l"
UBIOPTIONS="-m 512 -e 15KiB -c 3735 -F"
UBINIZE_OPTIONS="-m 512 -p 16KiB -s 512"
UBINIZECFG="/tmp/ubinize.cfg"
UBICOMPRESSION="zlib"
if grep -qs dm500hd /proc/stb/info/model ; then
   BOXTYPE=DM500HD
   BUILDOPTIONS=" --brcmnand -a dm500hd -e 0x4000 -f 0x4000000 -s 512 -b 0x40000:$DIRECTORY/secondstage.bin -d 0x3C0000:$DIRECTORY/boot.img -d 0x3C00000:$DIRECTORY/root.img"
fi
if grep -qs dm500hdv2 /proc/stb/info/model ; then
   BOXTYPE=DM500hdv2
   BUILDOPTIONS="-a dm500hdv2 --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0xF800000:$DIRECTORY/root.img"
   UBIBUILDOPTIONS="-a dm500hdv2 --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0x3F800000:$DIRECTORY/root.img"
   OPTIONS=" -e 0x20000 -n -l"
   UBIOPTIONS="-m 2048 -e 124KiB -c 3320 -F"
   UBINIZE_OPTIONS="-m 2048 -p 128KiB -s 2048"
   UBINIZE_VOLSIZE="402MiB"
   UBINIZE_DATAVOLSIZE="569MiB"
   UBICOMPRESSION="favor_lzo"
   CACHED="-c"
fi
if grep -qs dm800 /proc/stb/info/model ; then
   BOXTYPE=DM800
   BUILDOPTIONS=" --brcmnand -a dm800 -e 0x4000 -f 0x4000000 -s 512 -b 0x40000:$DIRECTORY/secondstage.bin -d 0x3C0000:$DIRECTORY/boot.img -d 0x3C00000:$DIRECTORY/root.img"
fi
if grep -qs dm800se /proc/stb/info/model ; then
   BOXTYPE=dm800se
   BUILDOPTIONS=" --brcmnand -a dm800se -e 0x4000 -f 0x4000000 -s 512 -b 0x40000:$DIRECTORY/secondstage.bin -d 0x3C0000:$DIRECTORY/boot.img -d 0x3C00000:$DIRECTORY/root.img"
fi
if grep -qs dm800sev2 /proc/stb/info/model ; then
   BOXTYPE=DM800sev2
   BUILDOPTIONS="-a dm800sev2 --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0xF800000:$DIRECTORY/root.img"
   UBIBUILDOPTIONS="-a dm800sev2 --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0x3F800000:$DIRECTORY/root.img"
   OPTIONS=" -e 0x20000 -n -l"
   UBIOPTIONS="-m 2048 -e 124KiB -c 3320 -F"
   UBINIZE_OPTIONS="-m 2048 -p 128KiB -s 2048"
   UBINIZE_VOLSIZE="402MiB"
   UBINIZE_DATAVOLSIZE="569MiB"
   UBICOMPRESSION="favor_lzo"
   CACHED="-c"
fi
if grep -qs dm8000 /proc/stb/info/model ; then
   BOXTYPE=DM8000
   BUILDOPTIONS="-a dm8000 -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0xF800000:$DIRECTORY/root.img"
   OPTIONS=" -e 0x20000 -n -l"
   UBIOPTIONS="-m 2048 -e 126KiB -c 1961 -F"
   UBINIZE_OPTIONS="-m 2048 -p 128KiB -s 512"
   UBICOMPRESSION="favor_lzo"
fi
if [ -e /proc/stb/info/vumodel -o -e /proc/stb/info/boxtype ]; then
   BOXTYPE=guest
   UBIOPTIONS="-m 2048 -e 124KiB -c 4096 -F"
   UBINIZE_OPTIONS="-m 2048 -p 128KiB"
   CACHED="-c"
fi
UBIBUILDOPTIONS=$BUILDOPTIONS
if grep -qs dm7020hd /proc/stb/info/model ; then
   BOXTYPE=DM7020HD
   if [ $BLOCKSIZE -eq 4096 ]; then
      BUILDOPTIONS="-a dm7020hd --brcmnand -e 0x40000 -f 0x10000000 -s 4096 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0xF800000:$DIRECTORY/root.img"
      UBIBUILDOPTIONS="-a dm7020hd --brcmnand -e 0x40000 -f 0x10000000 -s 4096 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0x3F800000:$DIRECTORY/root.img"
      OPTIONS=" -e 0x40000 -n -l"
      UBIOPTIONS="-m 4096 -e 248KiB -c 1640 -F"
      UBINIZE_OPTIONS="-m 4096 -p 256KiB -s 4096"
      UBINIZE_VOLSIZE="397MiB"
      UBINIZE_DATAVOLSIZE="574MiB"
   else
      BUILDOPTIONS="-a dm7020hd --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0xF800000:$DIRECTORY/root.img"
      UBIBUILDOPTIONS="-a dm7020hd --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0x3F800000:$DIRECTORY/root.img"
      OPTIONS=" -e 0x20000 -n -l"
      UBIOPTIONS="-m 2048 -e 124KiB -c 3320 -F"
      UBINIZE_OPTIONS="-m 2048 -p 128KiB -s 2048"
      UBINIZE_VOLSIZE="402MiB"
      UBINIZE_DATAVOLSIZE="569MiB"
   fi
   UBICOMPRESSION="favor_lzo"
   CACHED="-c"
fi

echo " "
echo "*********************"
echo "* "$BOXTYPE " FOUND *"
echo "*********************"
echo " "
echo "---------------------------------------------------------------"

DEBUG=$3
MOUNTPOINT=/tmp
VSND=$BOXTYPE
DATE=`date +%Y-%m-%d@%H.%M.%S`
SND=$DIRECTORY/secondstage.bin
Nanddump=/usr/bin/nanddump
MKFS=/usr/bin/mkfs.jffs2
UBIFS=/usr/bin/mkfs.ubifs
UBINIZE=/usr/bin/ubinize
SUMTOOL=/usr/bin/sumtool
BUILDIMAGE=/usr/bin/buildimage
BACKUPIMAGE=$DIRECTORY/BlackHole-OE2.0-$DATE.nfi

if [ ! -f $SND ] ; then
if [ -e /dev/mtd/1 ]; then
    $Nanddump --noecc --omitoob --bb=skipbad --truncate --file $DIRECTORY/secondstage.bin /dev/mtd/1 
  else
    $Nanddump --noecc --omitoob --bb=skipbad --truncate --file $DIRECTORY/secondstage.bin /dev/mtd1 
fi
fi

case "$DIRECTORY" in
	/media/net* )
		echo "Skipping SWAP-creation because the backup will be done to a network device"
	;;
	* )
  swapoff $DIRECTORY/swapfile_backup > /dev/null 2>&1
  rm -rf $DIRECTORY/swapfile_backup > /dev/null 2>&1
  echo "Creating swapfile on $DIRECTORY with "128"MB"
  dd if=/dev/zero of=$DIRECTORY/swapfile_backup bs=1024k count=128 >> $RAEDTMP 2>&1
  mkswap $DIRECTORY/swapfile_backup
  swapon $DIRECTORY/swapfile_backup
echo "---------------------------------------------------------------"
  echo "Swapfile activated"
echo "---------------------------------------------------------------"
	;;
esac

echo "***********************************************"
starttime="$(date +%s)"
echo "* FlashBackup started at: `date +%H:%M:%S`          *"
echo "***********************************************"

if [ -f /boot/autoexec.bat ]; then
touch /boot/dummy 2> /dev/null
fi

### External ###
if [ -f /boot/dummy ]; then
rm -rf /boot/dummy 2> /dev/null
    umount $MOUNTPOINT/bi/boot  2> /dev/null
	umount $MOUNTPOINT/bi/root  2> /dev/null  
	
	rm -rf $DIRECTORY/boot.img > /dev/null 2>&1
    rm -rf $DIRECTORY/boot.ubi > /dev/null 2>&1
    rm -rf $DIRECTORY/root.img > /dev/null 2>&1
    rm -rf $DIRECTORY/root.ubi > /dev/null 2>&1
	
    if [ ! -f /boot/autoexec.bat  ]; then
    if [ -f $MOUNTPOINT/bi/boot/autoexec.bat ] ; then	
       rm -r /boot   2> /dev/null            
       mv $MOUNTPOINT/bi/boot /boot  2> /dev/null
	fi
	fi
	
if [ -f $MOUNTPOINT/bi/root/usr/bin/enigma2 ] ; then
echo "******************************************************************"
echo "* (ROOT NOT UNMOUNT) Make reboot first then try to backup again  *" 
echo "******************************************************************"
exit 1 > /dev/null 2>&1
fi

rm -rf $MOUNTPOINT/bi/root > /dev/null 2>&1
mkdir -p $MOUNTPOINT/bi/root > /dev/null 2>&1
 
if grep -qs dm800sev2 /proc/stb/info/model ; then
mv /boot $MOUNTPOINT/bi/boot; cd $MOUNTPOINT/bi/boot; ln -sfn vmlinux-3.2-dm800sev2.gz vmlinux
ln -sfn /usr/share/bootlogo.mvi bootlogo.mvi; ln -sfn bootlog.mvi backdrop.mvi; ln -sfn bootlogo.mvi bootlogo_wait.mvi; cd /
sed -ie s!"root=/dev/mtdblock3 rootfstype=jffs2"!"ubi.mtd=root root=ubi0:rootfs rootfstype=ubifs"!g $MOUNTPOINT/bi/boot/autoexec*.bat
sed -ie s!"console=null"!"console=ttyS0,115200"!g $MOUNTPOINT/bi/boot/autoexec*.bat
sed -ie s!"quiet"!""!g $MOUNTPOINT/bi/boot/autoexec*.bat
else
mv /boot $MOUNTPOINT/bi/boot  > /dev/null 2>&1
fi
mkdir -p /boot  > /dev/null 2>&1            
mount -o bind / $MOUNTPOINT/bi/root > /dev/null 2>&1
if [ -e $MOUNTPOINT/bi/root/dev/usbdev1.1_ep00 ] ; then
   echo "Removing /dev/usbdev* (they will be back again after reboot)"
   rm -rf $MOUNTPOINT/bi/root/dev/usbdev* > /dev/null 2>&1
fi
	         echo "create boot.img"
		     $MKFS --root=$MOUNTPOINT/bi/boot --faketime --output=$DIRECTORY/boot.img $OPTIONS
	         UBI=0
			 dd if=/dev/mtdblock3 of=$RAEDTMP bs=3 count=1 > /dev/null 2>&1
             if [ `grep UBI $RAEDTMP | wc -l` -gt 0 ]; then
             echo  "UBIFS Filesystem ..." 
			 UBI=1
             echo \[root\] > $UBINIZECFG
             echo mode=ubi >> $UBINIZECFG
             echo image=$DIRECTORY/root.ubi >> $UBINIZECFG
             echo vol_id=0 >> $UBINIZECFG
             echo vol_name=rootfs >> $UBINIZECFG
             echo vol_type=dynamic >> $UBINIZECFG
             if [ $BOXTYPE != "dm7020hd" ]; then   
             echo vol_flags=autoresize >> $UBINIZECFG
             else 
             echo vol_size=$UBINIZE_VOLSIZE >> $UBINIZECFG
             echo \[data\] >> $UBINIZECFG
             echo mode=ubi >> $UBINIZECFG
             echo vol_id=1 >> $UBINIZECFG
             echo vol_type=dynamic >> $UBINIZECFG
             echo vol_name=data >> $UBINIZECFG
             echo vol_size=$UBINIZE_DATAVOLSIZE >> $UBINIZECFG
             echo vol_flags=autoresize >> $UBINIZECFG
             fi
             else
             echo  "jffs2 Filesystem ..." 
             fi
			 if [ $UBI -eq 1 ]; then
			   echo "create root.ubi"
			   echo "Relax 5 or 6 minutes until finishing"
			   echo "---------------------"
			   mkdir -p $MOUNTPOINT/bi/root 2> /dev/null
               $UBIFS $UBIOPTIONS -x $UBICOMPRESSION -r $MOUNTPOINT/bi/root -o $DIRECTORY/root.ubi
               $UBINIZE -o $DIRECTORY/root.img $UBINIZE_OPTIONS $UBINIZECFG
             else
			   echo "create root.img"
			   echo "Relax 5 or 6 minutes until finishing"
			   echo "---------------------"
			   mkdir -p $MOUNTPOINT/bi/root 2> /dev/null
               $MKFS --root=$MOUNTPOINT/bi/root --faketime --output=$DIRECTORY/root.img $OPTIONS 
             fi
			 echo "Build" $BOXTYPE "BlackHole OE2.0..."
	         if [ $BOXTYPE == "dm7020hd" -o $BOXTYPE == "dm8000" ]; then   
              if [ $UBI -eq 0 ]; then
                 $SUMTOOL --input=$DIRECTORY/boot.img --output=$DIRECTORY/boots.img $OPTIONS 
                 cp $DIRECTORY/boots.img $DIRECTORY/boot.img
                 rm $DIRECTORY/boots.img 
                 $SUMTOOL --input=$DIRECTORY/root.img --output=$DIRECTORY/roots.img $OPTIONS 
                 cp $DIRECTORY/roots.img $DIRECTORY/root.img
                 rm $DIRECTORY/roots.img 
              fi
              fi
              if [ $UBI -eq 1 ]; then
                 $BUILDIMAGE $UBIBUILDOPTIONS > $BACKUPIMAGE
                 else
                 $BUILDIMAGE $BUILDOPTIONS > $BACKUPIMAGE
              fi
         stoptime="$(date +%s)"
         elapsed_seconds="$(expr $stoptime - $starttime)"
		 umount $MOUNTPOINT/bi/root	 > /dev/null 2>&1	
         rm -r /boot > /dev/null 2>&1
		 mv $MOUNTPOINT/bi/boot /boot > /dev/null 2>&1
         exit 1 > /dev/null 2>&1
	  fi
### Internal ###
if [ ! -f /boot/dummy ]; then
umount $MOUNTPOINT/bi/boot  2> /dev/null
umount $MOUNTPOINT/bi/root  2> /dev/null

if [ -f $MOUNTPOINT/bi/root/usr/bin/enigma2 ] ; then
echo "******************************************************************"
echo "* (ROOT NOT UNMOUNT) Make reboot first then try to backup again  *" 
echo "******************************************************************"
exit 1 > /dev/null 2>&1
fi

if [ -f $MOUNTPOINT/bi/boot/autoexec.bat ] ; then
echo "******************************************************************"
echo "* (BOOT NOT UNMOUNT) Make reboot first then try to backup again  *"
echo "******************************************************************"
exit 1 > /dev/null 2>&1
fi

rm -rf $DIRECTORY/boot.img > /dev/null 2>&1
rm -rf $DIRECTORY/boot.ubi > /dev/null 2>&1
rm -rf $DIRECTORY/root.img > /dev/null 2>&1
rm -rf $DIRECTORY/root.ubi > /dev/null 2>&1

mkdir -p $MOUNTPOINT/bi/root > /dev/null 2>&1
mkdir -p $MOUNTPOINT/bi/boot > /dev/null 2>&1

if grep -qs dm800sev2 /proc/stb/info/model ; then
cp /boot/* $MOUNTPOINT/bi/boot; cd $MOUNTPOINT/bi/boot; ln -sfn vmlinux-3.2-dm800sev2.gz vmlinux
ln -sfn /usr/share/bootlogo.mvi bootlogo.mvi; ln -sfn bootlog.mvi backdrop.mvi; ln -sfn bootlogo.mvi bootlogo_wait.mvi; cd /
sed -ie s!"root=/dev/mtdblock3 rootfstype=jffs2"!"ubi.mtd=root root=ubi0:rootfs rootfstype=ubifs"!g $MOUNTPOINT/bi/boot/autoexec*.bat
sed -ie s!"console=null"!"console=ttyS0,115200"!g $MOUNTPOINT/bi/boot/autoexec*.bat
sed -ie s!"quiet"!""!g $MOUNTPOINT/bi/boot/autoexec*.bat
else
mount -t jffs2 $MTDBOOT $MOUNTPOINT/bi/boot
fi

	         echo "create boot.img From Flash"
		     $MKFS --root=$MOUNTPOINT/bi/boot --faketime --output=$DIRECTORY/boot.img $OPTIONS
	         echo "create root.img..."
			 echo "---------------------"
			 UBI=0
			 dd if=/dev/mtdblock3 of=$RAEDTMP bs=3 count=1 > /dev/null 2>&1
             if [ `grep UBI $RAEDTMP | wc -l` -gt 0 ]; then
             echo  "UBIFS Filesystem ..." 
			 UBI=1
             echo \[root\] > $UBINIZECFG
             echo mode=ubi >> $UBINIZECFG
             echo image=$DIRECTORY/root.ubi >> $UBINIZECFG
             echo vol_id=0 >> $UBINIZECFG
             echo vol_name=rootfs >> $UBINIZECFG
             echo vol_type=dynamic >> $UBINIZECFG
             if [ $BOXTYPE != "dm7020hd" ]; then   
             echo vol_flags=autoresize >> $UBINIZECFG
             else 
             echo vol_size=$UBINIZE_VOLSIZE >> $UBINIZECFG
             echo \[data\] >> $UBINIZECFG
             echo mode=ubi >> $UBINIZECFG
             echo vol_id=1 >> $UBINIZECFG
             echo vol_type=dynamic >> $UBINIZECFG
             echo vol_name=data >> $UBINIZECFG
             echo vol_size=$UBINIZE_DATAVOLSIZE >> $UBINIZECFG
             echo vol_flags=autoresize >> $UBINIZECFG
             fi
             else
             echo  "jffs2 Filesystem ..." 
             fi
             if [ $UBI -eq 1 ]; then
			   echo "create root.ubi"
			   echo "Relax 5 or 6 minutes until finishing"
			   echo "---------------------"
               mount -t ubifs /dev/ubi0_0 $MOUNTPOINT/bi/root
               $UBIFS $UBIOPTIONS -x $UBICOMPRESSION -r $MOUNTPOINT/bi/root -o $DIRECTORY/root.ubi 
               $UBINIZE -o $DIRECTORY/root.img $UBINIZE_OPTIONS $UBINIZECFG 
             else
			   echo "create root.img"
			   echo "Relax 5 or 6 minutes until finishing"
               mount -o bind / $MOUNTPOINT/bi/root > /dev/null 2>&1
			   if [ -e $MOUNTPOINT/bi/root/dev/usbdev1.1_ep00 ] ; then
               echo "Removing /dev/usbdev* (they will be back again after reboot)"
               rm -rf $MOUNTPOINT/bi/root/dev/usbdev* > /dev/null 2>&1
               fi
			   echo "---------------------"
               $MKFS --root=$MOUNTPOINT/bi/root --faketime --output=$DIRECTORY/root.img $OPTIONS 
             fi
			 echo "Build" $BOXTYPE "BlackHole OE2.0..."
			 if [ $BOXTYPE == "dm7020hd" -o $BOXTYPE == "dm8000" ]; then   
              if [ $UBI -eq 0 ]; then
                 $SUMTOOL --input=$DIRECTORY/boot.img --output=$DIRECTORY/boots.img $OPTIONS 
                 cp $DIRECTORY/boots.img $DIRECTORY/boot.img 
                 rm $DIRECTORY/boots.img 
                 $SUMTOOL --input=$DIRECTORY/root.img --output=$DIRECTORY/roots.img $OPTIONS
                 cp $DIRECTORY/roots.img $DIRECTORY/root.img 
                 rm $DIRECTORY/roots.img 
              fi
              fi
              if [ $UBI -eq 1 ]; then
                 $BUILDIMAGE $UBIBUILDOPTIONS > $BACKUPIMAGE
                 else
                 $BUILDIMAGE $BUILDOPTIONS > $BACKUPIMAGE
              fi
    stoptime="$(date +%s)"
    elapsed_seconds="$(expr $stoptime - $starttime)"
fi
echo "***********************************************"
echo "* FlashBackup finished at: `date +%H:%M:%S`            *"
echo "* Duration of FlashBackup: $((elapsed_seconds / 60))minutes $((elapsed_seconds % 60))seconds *"
echo "***********************************************"
exit 0 > /dev/null 2>&1
