#!/bin/bash
LOGFILE="/var/log/clamav/clamav-$(date +'%Y-%m-%d').log"
export TASKBADGER_API_KEY="evJPDu17.m4c0PRikHxd9UAln145DBBY8NdERhHbE"
export TASKBADGER_ORG="simongdkelly"
export TASKBADGER_PROJECT="clamav"

echo "Starting scan of '/home' directory. Log to $LOGFILE"
clamdscan --fdpass --quiet --log "$LOGFILE" /home
#clamdscan --multiscan --fdpass --quiet --log "$LOGFILE" /home
find /var/log/clamav/ -type f -mtime +30 -exec rm {} \;

MALWARE=$(cat "$LOGFILE"|grep Infected|cut -d" " -f3)

if [[ -n "$MALWARE" && "$MALWARE" != "0" ]]; then
    echo "Malware found: $MALWARE. See $LOGFILE."
    exit 1
fi

ERROR=$(cat "$LOGFILE"|grep ERROR)
if [[ $(grep -c "ERROR" $LOGFILE) -eq 1 ]]; then
    echo "ERRORs during scan. See $LOGFILE"
    exit 1
fi
