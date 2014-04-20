#!/bin/sh

RRD_FILE="/data/mydigitemp/mydigitemp.rrd"
DST_FILE="/www3/mydigitemp/$1.png"

RRD_PARAMETERS=' 
  $DST_FILE --end=$(date +%s) --vertical-label "Temperature .C" --width 1024 --height 600 --lower-limit 0
  DEF:temp0=$RRD_FILE:temp0:AVERAGE 
  DEF:temp1=$RRD_FILE:temp1:AVERAGE 
  LINE1:temp0#CF00FF:"10 minutes average inside\\n"
  LINE2:temp1#FF3C00:"10 minutes average outside\\n"
  COMMENT:" \\n"
  GPRINT:temp0:MIN:"Minimum inside\\: %4.1lf .C      "
  GPRINT:temp1:MIN:"Minimum outside\\: %4.1lf .C     "
  GPRINT:temp0:MAX:"Maximum inside\\: %4.1lf .C      "
  GPRINT:temp1:MAX:"Maximum outside\\: %4.1lf .C\\n"  
  GPRINT:temp0:AVERAGE:"Average inside\\: %4.1lf .C  "
  GPRINT:temp1:AVERAGE:"Average outside\\: %4.1lf .C "
  GPRINT:temp0:LAST:"Current inside\\: %4.1lf .C     "
  GPRINT:temp1:LAST:"Current outside\\: %4.1lf .C"
  > /dev/null
'

case $1 in
  daily)
    eval /usr/bin/rrdtool graph --start="end-2days" --title \'Daily graph [`date +"%F %H:%M"`]\' $RRD_PARAMETERS
  ;;
  weekly)
    eval /usr/bin/rrdtool graph --start="end-2week" --title \'Weekly graph [`date +"%F %H:%M"`]\' $RRD_PARAMETERS
  ;;
  monthly)
    eval /usr/bin/rrdtool graph --start="end-2month" --title \'Monthly graph [`date +"%F %H:%M"`]\' $RRD_PARAMETERS
  ;;
  yearly)
    eval /usr/bin/rrdtool graph --start="end-1year" --title \'Yearly graph [`date +"%F %H:%M"`]\' $RRD_PARAMETERS
  ;;
  2years)
    eval /usr/bin/rrdtool graph --start="end-2years" --title \'2 Years graph [`date +"%F %H:%M"`]\' $RRD_PARAMETERS
  ;;  
  5years)
    eval /usr/bin/rrdtool graph --start="end-5years" --title \'5 Years graph [`date +"%F %H:%M"`]\' $RRD_PARAMETERS
  ;;
  10years)
    eval /usr/bin/rrdtool graph --start="end-10years" --title \'10 Years graph [`date +"%F %H:%M"`]\' $RRD_PARAMETERS
  ;;
  *)
    echo "Please specify $0 [daily|weekly|monthly|yearly|2years|5years|10years]"
  ;;
esac
