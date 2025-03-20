#!/bin/bash
#
# Script: backup.sh
# Author: Tordt Schmidt
# Date: 2025-03-14
# Version: 1.0
#
# Description:
# This script performs incremental backups of a filesystem to a NAS.
#
# DISCLAIMER:
# This script is provided "as-is," without any warranties or guarantees of any kind,
# either express or implied. The author disclaims all liability for any damages,
# losses, or issues arising from the use of this script. Use at your own risk.
#
# License:
# This script is distributed under the MIT License.
# For full license terms, see: https://opensource.org/licenses/MIT
#
# You are free to modify and distribute this script, but please retain this header.
#
# Usage:
# create a cronjob like this
# 0 4 * * * /root/backup.sh
#


# Configuration
NAS_MOUNT="/mnt/backup"
NAS_SHARE="127.0.0.1:/path/to/your/share"  # Replace with your NAS IP and share path
BACKUP_FILE="$NAS_MOUNT/backup.img"
LOG_FILE="/var/log/backup.log"
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")

log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}
log "################################"
log "Starting backup"
# 1. Mount NAS folder
if ! mountpoint -q "$NAS_MOUNT"; then
    if ! mount -t nfs "$NAS_SHARE" "$NAS_MOUNT"; then
        log "ERROR: NAS not available, exiting."
        exit 1
    fi
fi

# 2. Check last backup date and rename if older than 7 days
if [ -f "$BACKUP_FILE" ]; then
    LAST_CTIME=$(stat -c %Z "$BACKUP_FILE")
    CURRENT_TIME=$(date +%s)
    AGE_DAYS=$(( (CURRENT_TIME - LAST_CTIME) / 86400 ))
    if [ "$AGE_DAYS" -ge 7 ]; then
        mv "$BACKUP_FILE" "$NAS_MOUNT/backup_$TIMESTAMP.img"
        log "Old backup renamed to backup_$TIMESTAMP.img"
    fi
fi

# 3. Delete images older than 4 weeks
OLD_IMAGES=$(find "$NAS_MOUNT" -type f -name "*.jpg" -ctime +28)
if [ -n "$OLD_IMAGES" ]; then
    echo "$OLD_IMAGES" | xargs rm -f
echo "removed backups older than a month"
fi

# 4. Run image-backup

# Get modification time before backup
if [ -f "$BACKUP_FILE" ]; then
    PRE_BACKUP_MTIME=$(stat -c %Y "$BACKUP_FILE")
else
    PRE_BACKUP_MTIME=0
fi

# Perform backup
if [ -f "$BACKUP_FILE" ]; then
    log "starting incremental backup"
    /usr/local/bin/image-backup "$BACKUP_FILE"
else
    log "starting full backup"
    /usr/local/bin/image-backup -i "$BACKUP_FILE"
fi

# Get modification time after backup
if [ -f "$BACKUP_FILE" ]; then
    POST_BACKUP_MTIME=$(stat -c %Y "$BACKUP_FILE")
else
    POST_BACKUP_MTIME=0
fi

# Verify if backup was successful
if [ "$POST_BACKUP_MTIME" -gt "$PRE_BACKUP_MTIME" ]; then
    log "Backup completed successfully."
else
    log "ERROR: Backup may have failed; file modification time did not change."
fi

# 5. Unmount NAS folder
# 5. Unmount NAS folder
log "Attempting to unmount NAS..."
TIMEOUT=30  # 5 minutes in seconds
START_TIME=$(date +%s)

while true; do
    sync
    if umount "$NAS_MOUNT"; then
        log "NAS unmounted successfully."
        break
    else
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        if [ "$ELAPSED_TIME" -ge "$TIMEOUT" ]; then
            log "ERROR: Failed to unmount NAS after 5 minutes. Device may still be busy."
            exit 1
        fi
      sleep 5
    fi
done
