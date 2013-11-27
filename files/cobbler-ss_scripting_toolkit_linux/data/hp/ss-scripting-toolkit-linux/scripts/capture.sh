#!/bin/bash

## SAMPLE. Change the mount points to match your environment
PROFILE_DIR=${sstk_mount}
PROFILE_TYPE=${sstk_mount_type}
test -n "$sstk_mount_options" && PROFILE_OPTS="-o $sstk_mount_options"

export PROFILENAME=${img}

## Internal Variables, do not modify
export TOOLKIT=/TOOLKIT
export PROFILE_MNT=/mnt/nfs
export HWDISC_FILE=/TOOLKIT/hpdiscovery.xml
export SERVERNAME=
export BOOTDEVNODE=

clear
echo "*** Capturing Configuration ***"

mkdir -p ${TOOLKIT}/data_files/

echo ""
echo "Loading storage drivers for hardware"
cd ${TOOLKIT}
./load_modules.sh


echo ""
echo "Pausing to allow drivers to finish loading"
sleep 15
echo ""

## rerun hardware discovery 
./hpdiscovery -f ${HWDISC_FILE}
echo "Hardware Discovery saved to ${HWDISC_FILE}"


## use hwquery to fetch the SystemName and BootDeviceNode from hardware discovery file. ( extra " " are required ) 
export "`./hwquery ${HWDISC_FILE} allboards.xml SERVERTYPE=SystemName`"
export "`./hwquery ${HWDISC_FILE} allboards.xml BOOTDEVNODE=DevNode`";

echo "Server Type: ${SERVERTYPE}"

mkdir -p ${TOOLKIT}/data_files/
./conrep -s -f${TOOLKIT}/data_files/conrep.dat
if [ $? = 0 ] ; then
	echo "System Configuration saved to ${TOOLKIT}/data_files/conrep.dat"
fi

./ifhw ${HWDISC_FILE} allboards.xml "PCI:Smart Array" 2> /dev/null
if [ $? = 0 ] ; then
	hpacuscripting -c ${TOOLKIT}/data_files/cpqacuxe.dat
	if [ $? = 0 ] ; then
		echo "Array Configuration saved to ${TOOLKIT}/data_files/cpqacuxe.dat"
	fi
else
	echo "No Smart Array detected, no ACU Configuration captured."
fi

cd ${TOOLKIT}
./ifhw ${HWDISC_FILE} allboards.xml "PCI:Integrated Lights-Out" 2> /dev/null
if [ $? = 0 ] ; then
	modprobe hpilo
	./hponcfg -w data_files/hponcfg.dat 
	if [ $? = 0 ] ; then
		echo "Integrated Lights-Out Configuration Report saved to ${TOOLKIT}/data_files/hponcfg.dat"
		echo " - this is not a RIBCL configuration script"
	fi
fi

if [ "$img" = "" ] ; then
        echo "No image name specified, add img=<name> parameter to the boot line to capture a complete profile."
        echo "System configuration captured to /TOOLKIT/data_files/"
        echo "copy these files to another location, then type exit or CTRL-D to reboot"
        /bin/bash
        ${TOOLKIT}/reboot
fi

echo "Mounting Storage ${PROFILE_DIR}"
mkdir ${PROFILE_MNT}
mount -t ${PROFILE_TYPE} ${PROFILE_DIR} ${PROFILE_MNT} ${PROFILE_OPTS}
if [ $? = 0 ] ; then
	mkdir ${PROFILE_MNT}/blade_configs/$PROFILENAME
	cp -a ${TOOLKIT}/data_files ${PROFILE_MNT}/blade_configs/$PROFILENAME

	#partimage -z1 -o -d save ${BOOTDEVNODE} ${PROFILE_MNT}/blade_configs/$PROFILENAME/bootdrive.img
	if [ $? = 0 ] ; then
		echo ""
		echo " System Captured to $PROFILENAME"
	fi
	umount ${PROFILE_DIR}
fi

sleep 30
poweroff -f
