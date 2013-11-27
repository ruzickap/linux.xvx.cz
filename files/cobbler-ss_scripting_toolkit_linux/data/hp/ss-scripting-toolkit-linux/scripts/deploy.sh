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
echo "*** Deploying Configuration ***"

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

## use hwquery to fetch the SystemName from hardware discovery file. ( extra " " are required ) 
export "`./hwquery ${HWDISC_FILE} allboards.xml SERVERTYPE=SystemName`";

echo "Server Type: ${SERVERTYPE}"

echo "Mounting Storage ${PROFILE_DIR}"
mkdir ${PROFILE_MNT}
mount -t ${PROFILE_TYPE} ${PROFILE_DIR} ${PROFILE_MNT} ${PROFILE_OPTS}
if [ $? = 0 ] ; then
	echo "APPLYING ${PROFILENAME}"
	cp -a ${PROFILE_MNT}/blade_configs/${PROFILENAME}/data_files ${TOOLKIT}

	./conrep -l -f${TOOLKIT}/data_files/conrep.dat
	if [ $? = 0 ] ; then
		echo "System Configuration data_files/conrep.dat APPLIED"
	else
		echo "System Configuration data_files/conrep.dat FAILED"
	fi

	./ifhw ${HWDISC_FILE} allboards.xml "PCI:Smart Array" 2> /dev/null
	if [ $? = 0 ] ; then
		hpacuscripting -i ${TOOLKIT}/data_files/cpqacuxe.dat
		if [ $? = 0 ] ; then
			echo "Array Configuration data_files/cpqacuxe.dat APPLIED"
		else
			echo "Array Configuration data_files/cpqacuxe.dat FAILED"
		fi
	else
		echo "No Smart Array detected, no ACU Configuration applied."
	fi

	cd ${TOOLKIT}
	./ifhw ${HWDISC_FILE} allboards.xml "PCI:Integrated Lights-Out" 2> /dev/null
	if [ $? = 0 ] ; then
		modprobe hpilo
		./hponcfg -f data_files/hponcfg.dat 
		if [ $? = 0 ] ; then
			echo "Integrated Lights-Out Configuration data_files/hponcfg.dat APPLIED"
		fi
	fi

	export "`./hwquery ${HWDISC_FILE} allboards.xml BOOTDEVNODE=DevNode`";
	if [ -f ${PROFILE_MNT}/blade_configs/${PROFILENAME}/bootdrive.img ] ; then
		#partimage restore ${BOOTDEVNODE} ${PROFILE_MNT}/blade_configs/${PROFILENAME}/bootdrive.img
		if [ $? = 0 ] ; then
			echo ""
			echo " System Captured to $PROFILENAME"
		fi
	fi
	umount ${PROFILE_DIR}
fi

sleep 30
poweroff -f
