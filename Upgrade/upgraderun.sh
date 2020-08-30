#!/bin/sh
set -e

ls -al /tmp/Upgrade
cat /tmp/Upgrade/flash_bootloader.sh
sh /tmp/Upgrade/flash_bootloader.sh &> /media/mmcblk0p1/wyze-cam-pan-fix.log
