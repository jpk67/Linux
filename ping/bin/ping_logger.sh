#!/bin/bash

DATE=$(date +%Y_%m_%d)    #get date YYYY_MM_DD_HH_MM_SS
LOGS=/home/jpk/ping/logs
DFILE=${LOGS}/details_$DATE.log
SFILE=${LOGS}/summary_$DATE.log

# Housekeeping - keep last 14 days of logs only
find ${LOGS} -mtime 14 -print -exec rm '{}' \;

site=www.google.co.uk

#ping -D $site >> $DFILE 2>&1 &
#
#sleep 1
#
#tail -100f $DFILE  | gawk -f ~/bin/ping.gawk | tee -a $SFILE

ping -D $site 2>&1 | tee $DFILE | gawk -f ~/bin/ping.gawk | tee -a $SFILE

