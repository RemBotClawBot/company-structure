#!/bin/bash
# Daily Incremental Backup Script
# Location: /root/company-structure/scripts/daily-backup.sh
# Run via cron: 0 2 * * * /root/company-structure/scripts/daily-backup.sh
# Backup retention: 7 days

set -euo pipefail

# Configuration
BACKUP_DIR="/opt/gitea/data.backup/daily"
LOG_FILE="/var/log/daily-backup.log"
DATE=$(date +%Y%m%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
RETENTION_DAYS=7

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR/$DATE"

echo "=== Daily Backup Started at $TIMESTAMP ===" | tee -a "$LOG_FILE"

# Backup Gitea data
echo "Starting Gitea data backup..." | tee -a "$LOG_FILE"
if [ -d "/opt/gitea/data" ]; then
    rsync -av --delete \
        --exclude="*.log" \
        --exclude="*.tmp" \
        /opt/gitea/data/ \
        "$BACKUP_DIR/$DATE/data/" 2>&1 | tee -a "$LOG_FILE"
    echo "Gitea data backup completed" | tee -a "$LOG_FILE"
else
    echo "ERROR: /opt/gitea/data directory not found!" | tee -a "$LOG_FILE"
    exit 1
fi

# Backup configuration files
echo "Backing up configuration files..." | tee -a "$LOG_FILE"
if [ -f "/opt/gitea/app.ini" ]; then
    cp /opt/gitea/app.ini "$BACKUP_DIR/$DATE/app.ini.backup" 2>&1 | tee -a "$LOG_FILE"
fi

if [ -f "/root/.openclaw/config.yaml" ]; then
    cp /root/.openclaw/config.yaml "$BACKUP_DIR/$DATE/config.yaml.backup" 2>&1 | tee -a "$LOG_FILE"
fi

# Backup SSH keys
echo "Backing up SSH keys..." | tee -a "$LOG_FILE"
if [ -d "/root/.ssh" ]; then
    mkdir -p "$BACKUP_DIR/$DATE/ssh.backup"
    cp -r /root/.ssh/* "$BACKUP_DIR/$DATE/ssh.backup/" 2>&1 | tee -a "$LOG_FILE"
fi

# Create manifest file
echo "Creating backup manifest..." | tee -a "$LOG_FILE"
cat > "$BACKUP_DIR/$DATE/manifest.json" << EOF
{
  "backup_date": "$TIMESTAMP",
  "backup_type": "daily_incremental",
  "items": [
    {
      "path": "/opt/gitea/data",
      "backup_size": "$(du -sh $BACKUP_DIR/$DATE/data/ | cut -f1)"
    },
    {
      "path": "/opt/gitea/app.ini",
      "backup_size": "$(stat -c%s /opt/gitea/app.ini 2>/dev/null || echo 0)"
    },
    {
      "path": "/root/.openclaw/config.yaml",
      "backup_size": "$(stat -c%s /root/.openclaw/config.yaml 2>/dev/null || echo 0)"
    },
    {
      "path": "/root/.ssh",
      "backup_size": "$(du -sh $BACKUP_DIR/$DATE/ssh.backup/ 2>/dev/null | cut -f1 || echo 0)"
    }
  ],
  "system_info": {
    "hostname": "$(hostname)",
    "disk_usage": "$(df -h / | tail -1)",
    "memory_usage": "$(free -h | grep Mem | awk '{print $3 "/" $2}')",
    "load_average": "$(uptime | awk -F'load average:' '{print $2}')"
  }
}
EOF

# Rotate old backups
echo "Applying retention policy ($RETENTION_DAYS days)..." | tee -a "$LOG_FILE"
find "$BACKUP_DIR" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null || true

# Clean up empty directories
find "$BACKUP_DIR" -type d -empty -delete 2>/dev/null || true

# Generate verification report
BACKUP_COUNT=$(find "$BACKUP_DIR" -type d -name "data" | wc -l)
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)

echo "=== Daily Backup Summary ===" | tee -a "$LOG_FILE"
echo "Backup location: $BACKUP_DIR/$DATE" | tee -a "$LOG_FILE"
echo "Total backup sets retained: $BACKUP_COUNT" | tee -a "$LOG_FILE"
echo "Total backup storage used: $TOTAL_SIZE" | tee -a "$LOG_FILE"
echo "Backup completed at: $(date +"%Y-%m-%d %H:%M:%S")" | tee -a "$LOG_FILE"
echo "=================================" | tee -a "$LOG_FILE"

# Send notification (if configured)
if [ -f "/root/.openclaw/config.yaml" ]; then
    # Could be extended to send Discord/Telegram notification
    echo "Backup completed successfully" | tee -a "$LOG_FILE"
fi

exit 0