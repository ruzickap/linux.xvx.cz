#!/bin/sh
# Failover command for streaming replication.
#
# Arguments: $1: failed node id. $2: new master hostname.
 
failed_node=$1
new_master=$2
 
(
date
echo "Failed node: $failed_node"
set -x
 
/usr/bin/ssh -T -l postgres $new_master "/usr/pgsql-9.3/bin/repmgr -f /var/lib/pgsql/repmgr/repmgr.conf standby promote 2>/dev/null 1>/dev/null <&-"
 
exit 0;
) 2>&1 | tee -a /tmp/failover_stream.sh.log
