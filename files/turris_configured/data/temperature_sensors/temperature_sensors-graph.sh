#!/bin/sh
 
NAME=$(echo $0 | sed 's@.*/\([^-]*\)-.*@\1@')
RRD_FILE="/data/$NAME/$NAME.rrd"
DST_FILE="/www3/$NAME/$1.png"
 
RRD_PARAMETERS='
  $DST_FILE --end=$(date +%s) --vertical-label "Temperature .C" --width 1024 --height 600 --lower-limit 0
  DEF:temp0=$RRD_FILE:temp0:AVERAGE
  DEF:temp1=$RRD_FILE:temp1:AVERAGE
  LINE1:temp0#CF00FF:"10 minutes average Board\\n"
  LINE2:temp1#FF3C00:"10 minutes average CPU\\n"
  COMMENT:" \\n"
  GPRINT:temp0:MIN:"Minimum Board\\: %4.1lf .C      "
  GPRINT:temp1:MIN:"Minimum CPU\\: %4.1lf .C     "
  GPRINT:temp0:MAX:"Maximum Board\\: %4.1lf .C      "
  GPRINT:temp1:MAX:"Maximum CPU\\: %4.1lf .C\\n"
  GPRINT:temp0:AVERAGE:"Average Board\\: %4.1lf .C  "
  GPRINT:temp1:AVERAGE:"Average CPU\\: %4.1lf .C "
  GPRINT:temp0:LAST:"Current Board\\: %4.1lf .C     "
  GPRINT:temp1:LAST:"Current CPU\\: %4.1lf .C"
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
