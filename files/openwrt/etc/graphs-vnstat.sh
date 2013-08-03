#!/bin/sh
# vnstati image generation script.
# Source:  https://code.google.com/p/x-wrt/source/browse/package/webif/files/www/cgi-bin/webif/graphs-vnstat.sh
 
WWW_D=/www/myadmin/vnstat # output images to here
LIB_D=`awk -F \" '/^DatabaseDir/ { print $2 }' /etc/vnstat.conf` # db location
BIN=/usr/bin/vnstati  # which vnstati
 
outputs="s h d t m"   # what images to generate
 
# Sanity checks
[ -d "$WWW_D" ] || mkdir -p "$WWW_D" # make the folder if it doesn't exist.

# End of config changes
interfaces="$(ls -1 $LIB_D)"
 
if [ -z "$interfaces" ]; then
    echo "No database found, nothing to do."
    echo "A new database can be created with the following command: "
    echo "    vnstat -u -i eth0"
    exit 0
else
    for interface in $interfaces; do
        for output in $outputs; do
            $BIN -${output} -i $interface -o $WWW_D/vnstat_${interface}_${output}.png
        done
    done
fi
 
exit 1
