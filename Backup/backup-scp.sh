#!/bin/bash

# Simple backup scripts that backs up an application running as a user systemd service.
# It will stop the application, create a filesystem snapshot, and then immediately start the application. This ensures that backed up data is consistent.
# Tested only with thin LVs.

# --- Schedule with cron                   ---
# --- Wrap in another script to log output ---

# Set variables
BACKUP_FILE="/lvmdata/backup-$(date +%Y-%m-%d-%H-%M).tar.gz"

# Stop the service
sudo -u seafile -i systemctl --user stop seafile.service
# Make a thin snapshot
lvcreate -s --name seafile-snap rocky/seafile
# Start the service
sudo -u seafile -i systemctl --user start seafile.service

# Mount snapshot
mkdir /home/seafile-snap
lvchange -ay -Ky rocky/seafile-snap
mount -o nouuid /dev/rocky/seafile-snap /home/seafile-snap

# Tar
nice -n 100 tar czf "$BACKUP_FILE" "/home/seafile-snap"

# Transfer
scp "$BACKUP_FILE" root@server:/root/backups

# Delete tar
rm -f "$BACKUP_FILE"

# Unmount and destroy snapshot
umount /home/seafile-snap
rmdir /home/seafile-snap
lvremove -y /dev/rocky/seafile-snap
