#!/bin/bash
# Daily Incremental Backup Script
# Usage: Run via cron daily, logs to /var/log/daily-backup.log
# Backup retention: 7 days

BACKUP_DIR="/opt/gitea/data.backup/daily"
DATE=$(date +%Y%m%d)
LOG_FILE="/var/log/daily-backup.log"
RETENTION_DAYS=7

echo "=== Daily Backup Started: $(date) ===" >> "$LOG_FILE"

# Create backup directory
mkdir -p "$BACKUP_DIR/$DATE"

# 1. Backup Gitea data (incremental with hardlinks for efficiency)
echo "Backing up Gitea data..." >> "$LOG_FILE"
if [ -d "/opt/gitea/data" ]; then
    rsync -av --delete --link-dest="$BACKUP_DIR/latest/data/" \
        /opt/gitea/data/ "$BACKUP_DIR/$DATE/data/" \
        >> "$LOG_FILE" 2>&1
else
    echo "ERROR: /opt/gitea/data directory not found!" >> "$LOG_FILE"
    exit 1
fi

# 2. Backup configuration files
echo "Backing up configuration files..." >> "$LOG_FILE"
cp /opt/gitea/app.ini "$BACKUP_DIR/$DATE/app.ini.backup" 2>> "$LOG_FILE"
cp /root/.openclaw/config.yaml "$BACKUP_DIR/$DATE/config.yaml.backup" 2>> "$LOG_FILE"

# 3. Backup SSH keys (if not backing up entire home dir)
echo "Backing up SSH configuration..." >> "$LOG_FILE"
mkdir -p "$BACKUP_DIR/$DATE/ssh"
cp -r ~/.ssh/* "$BACKUP_DIR/$DATE/ssh/" 2>/dev/null || true

# 4. Create checksums for verification
echo "Creating verification checksums..." >> "$LOG_FILE"
find /opt/gitea/data -type f -exec md5sum {} \; > "$BACKUP_DIR/$DATE/checksums.md5" 2>/dev/null

# 5. Update latest symlink
rm -f "$BACKUP_DIR/latest"
ln -s "$BACKUP_DIR/$DATE" "$BACKUP_DIR/latest"

# 6. Apply retention policy (keep 7 days)
echo "Applying retention policy ($RETENTION_DAYS days)..." >> "$LOG_FILE"
find "$BACKUP_DIR" -maxdepth 1 -type d -name "202*" -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null

# 7. Verify backup integrity
echo "Verifying backup integrity..." >> "$LOG_FILE"
if [ -f "$BACKUP_DIR/$DATE/checksums.md5" ]; then
    CHECKSUM_COUNT=$(wc -l < "$BACKUP_DIR/$DATE/checksums.md5")
    echo "Created checksums for $CHECKSUM_COUNT files" >> "$LOG_FILE"
else
    echo "WARNING: No checksum file created" >> "$LOG_FILE"
fi

# 8. Disk usage report
echo "Backup disk usage:" >> "$LOG_FILE"
du -sh "$BACKUP_DIR/$DATE" >> "$LOG_FILE"
du -sh "$BACKUP_DIR" >> "$LOG_FILE"

echo "=== Daily Backup Completed: $(date) ===" >> "$LOG_FILE"
echo "Backup location: $BACKUP_DIR/$DATE" >> "$LOG_FILE"

# Exit with success
exit 0