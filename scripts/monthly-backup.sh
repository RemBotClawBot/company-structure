#!/bin/bash
# Monthly Full Backup Script
# Usage: Run via cron on the 1st day of each month at 03:00
# Stops Gitea service, captures full backup, verifies integrity, retains 12 months of backups

BACKUP_DIR="/opt/gitea/data.backup/monthly"
DATE=$(date +%Y%m)
LOG_DIR="$BACKUP_DIR/$DATE"
LOG_FILE="$LOG_DIR/backup.log"
RETENTION_MONTHS=12

mkdir -p "$LOG_DIR"
echo "=== Monthly Backup Started: $(date) ===" | tee -a "$LOG_FILE"

echo "Stopping Gitea service..." | tee -a "$LOG_FILE"
systemctl stop gitea
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to stop Gitea service" | tee -a "$LOG_FILE"
fi

echo "Creating full backup archive..." | tee -a "$LOG_FILE"
tar -czf "$LOG_DIR/full-backup.tar.gz" \
    /opt/gitea \
    /root/.openclaw \
    ~/.ssh \
    /etc/ssh \
    /var/lib/systemd/coredump \
    /etc/crontab \
    /opt/scripts \
    /var/log \
    2>&1 | tee -a "$LOG_FILE"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "ERROR: Backup archive creation failed" | tee -a "$LOG_FILE"
    systemctl start gitea
    exit 1
fi

echo "Generating checksum manifest..." | tee -a "$LOG_FILE"
find /opt/gitea -type f -exec md5sum {} \; > "$LOG_DIR/checksums.md5" 2>/dev/null

echo "Restarting Gitea service..." | tee -a "$LOG_FILE"
systemctl start gitea
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to restart Gitea service" | tee -a "$LOG_FILE"
    exit 1
fi

echo "Verifying backup archive integrity..." | tee -a "$LOG_FILE"
tar -tzf "$LOG_DIR/full-backup.tar.gz" > /dev/null
if [ $? -eq 0 ]; then
    echo "Backup verification: SUCCESS" | tee -a "$LOG_FILE"
    du -h "$LOG_DIR/full-backup.tar.gz" | tee -a "$LOG_FILE"
else
    echo "Backup verification: FAILED" | tee -a "$LOG_FILE"
    exit 1
fi

echo "Applying retention policy (keep $RETENTION_MONTHS months)..." | tee -a "$LOG_FILE"
find "$BACKUP_DIR" -maxdepth 1 -type d -mtime +$((RETENTION_MONTHS*30)) -exec rm -rf {} \; 2>/dev/null

# Cleanup old log files
find "$BACKUP_DIR" -type f -name "backup.log" -mtime +$((RETENTION_MONTHS*30)) -delete

echo "Monthly backup completed at $(date)" | tee -a "$LOG_FILE"
exit 0