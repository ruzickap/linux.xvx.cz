#!/bin/bash

### Custom bash script for
### SmartStart Scripting Toolkit for Linux v1.7
### July 2007
### JimmyV

####
#
# WARNING THIS SCRIPT RESETS SYSTEM TO FACTORY DEFAULTS
# DESTROYING:
#            ANY DATA ON ATTACHED HARD DISKS
#            RAID CONFIGURATION 
#            SETTINGS IN NVRAM
#            ILO USER AND NETWORK INFORMATION 
#
####

clear
BOLD_ON=`tput bold`
ATTRIBUTES_OFF=`tput sgr0`

cat << EOF 

                   ${BOLD_ON}SmartStart Scripting Toolkit for Linux${ATTRIBUTES_OFF}
                                       
		                     S Y S T E M  R E S E T

  ${BOLD_ON}**WARNING**WARNING**WARNING**WARNING**WARNING**WARNING**WARNING**WARNING**${ATTRIBUTES_OFF}

  ${BOLD_ON}Any existing configurations and data on this system will be lost${ATTRIBUTES_OFF}


${BOLD_ON}THIS SCRIPT IS PROVIDED BY HP WITHOUT WARRANTY
          USE WITH EXTREME CAUTION${ATTRIBUTES_OFF}

EOF
echo -n "${BOLD_ON}Are you absolutely sure you want to do this?${ATTRIBUTES_OFF} [y/N]: "
read ANSWER
case "${ANSWER}" in
	[yY] | [yY][eE][sS])
		### CONTINUE ###
		;;
	*)
		echo ".......... ABORTING .........."
		echo ""
		echo -e "Power off system\n"
		exec /bin/bash &>/dev/null
		;;
esac

clear

echo -e "*** Executing script to reset system to factory defaults (systemreset.sh)\n"
sleep 5s

### Get environment variables
### must use absolute path here
source /TOOLKIT/includes

echo -e "*** Copying over toolkit scripts and utilites from NFS mount ***"
cd ${TOOLKIT}
#cp -a ${RAM_TOOLKIT_DIR}/scripts/* ${TOOLKIT}
#cp -a ${RAM_TOOLKIT_DIR}/utilities/* ${TOOLKIT}
echo -e "*** Scripts will continue execution from RAM drive ***\n"

echo -e "Loading storage drivers"
./load_modules.sh
echo -e "...Pausing to allow drivers to finish loading\n"
sleep 2s
 
function ResetArrayController() {

cat << EOF

Action = Reconfigure
Method = Custom

Controller = All
ClearConfigurationWithDataLoss = Yes

EOF
}

cd ${TOOLKIT}

# Uncomment only if your not running script over iLO remote console
# or you know the factory Administrator user password
   
# echo -e "\n*** RESETTING iLO now... ***"
# ./hponcfg -r

echo -e "*** Resetting NVRAM to factory defaults ***\n"
./rbsureset #-reset
sleep 2s

echo -e "*** Resetting Smart Arrays to factory defaults ***\n"

ResetArrayController > ResetSA.dat

hpacuscripting -i ResetSA.dat 
sleep 2s

cd ${TOOLKIT}

echo "*** System reset completed..."
echo "    -system will reboot in 30 seconds"
sleep 30s

poweroff -f

echo "WAH if your seeing this something bad happened!!!!"
exec /bin/bash


