[ -f /etc/profile ] && source /etc/profile
PGDATA=/var/lib/pgsql/9.3/data
export PGDATA
PATH=/usr/pgsql-9.3/bin:$PATH
