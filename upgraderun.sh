#!/bin/sh -e

echo "Changing to upgrade directory."
cd /tmp/Upgrade
echo "Verifying file integrity."
md5sum -c wyzecam_v2_stock_bootloader.bin.md5
echo "Backing up current bootloader."
dd if=/dev/mtd0 of=/media/mmcblk0p1/old-bootloader.bin
echo "Erasing bootloader flash."
flash_eraseall /dev/mtd0
echo "Installing replacement bootloader."
dd if=wyzecam_v2_stock_bootloader.bin of=/dev/mtd0
