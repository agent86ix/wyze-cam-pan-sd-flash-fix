#!/bin/sh
set -e

if [ -d "/media/mmcblk0p1/" ]
then
    BACKUP_DIR=/media/mmcblk0p1/
elif [ -d "/media/mmc/" ]
then
    BACKUP_DIR=/media/mmc/
else
    BACKUP_DIR=`mount | grep mmc | grep -v -e /root -e /etc -e /bin | cut -d ' ' -f 3`
fi

if [ ! -d $BACKUP_DIR ]
then
    exit 1
fi

sh /tmp/Upgrade/flash_bootloader.sh $BACKUP_DIR &> $BACKUP_DIR/wyze-cam-pan-fix.log
