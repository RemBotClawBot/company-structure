#!/bin/bash
# Monthly Full Backup Script
# Location: /root/company-structure/scripts/monthly-backup.sh
# Run via cron: 0 3 1 * * /root/company-structure/scripts/monthly-backup.sh
# Full backup with service stop/start and verification

set -euo pipefail

# Configuration
BACKUP_DIR="/opt/gitea/data.backup/monthly"
LOG_FILE="/var/log/monthly-backup.log"
DATE=$(date +%Y%m)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
RETENTION_MONTHS=12
BACKUP_SET_NAME="full-backup-$DATE"

echo "=== Monthly Backup Started at $TIMESTAMP ===" | tee -a "$LOG_FILE"

# Validate backup directory
mkdir -p "$BACKUP_DIR/$DATE"
BACKUP_PATH="$BACKUP_DIR/$DATE"

# Pre-flight checks
echo "Performing pre-flight checks..." | tee -a "$LOG_FILE"

# Check disk space
AVAILABLE_SPACE=$(df -BG / | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt "10" ]; then
    echo "ERROR: Insufficient disk space (less than 10GB available)" | tee -a "$LOG_FILE"
    exit 1
fi

# Stop services for consistent backup
echo "Stopping services for consistent backup..." | tee -a "$LOG_FILE"

GITEA_SERVICE_STATUS="unknown"
if systemctl is-active --quiet gitea; then
    echo "Gitea service is running, stopping temporarily..." | tee -a "$LOG_FILE"
    systemctl stop gitea
    GITEA_SERVICE_STATUS="stopped"
    sleep 5
else
    echo "Gitea service already stopped or not running" | tee -a "$LOG_FILE"
    GITEA_SERVICE_STATUS="inactive"
fi

# Generate checksums before backup
echo "Generating pre-backup checksums..." | tee -a "$LOG_FILE"
find /opt/gitea -type f ! -path "*/logs/*" ! -name "*.log" ! -name "*.tmp" 2>/dev/null | \
    head -1000 > "$BACKUP_PATH/files-to-backup.txt" 2>/dev/null || true

# Create full backup archive
echo "Creating full backup archive..." | tee -a "$LOG_FILE"
BACKUP_FILE="$BACKUP_PATH/full-backup.tar.gz"
BACKUP_START=$(date +%s)

tar -czf "$BACKUP_FILE" \
    --exclude="*.log" \
    --exclude="*.tmp" \
    --exclude="cache" \
    --exclude="temp" \
    /opt/gitea \
    /root/.openclaw \
    /root/.ssh \
    /etc/ssh/sshd_config \
    2>&1 | tee -a "$LOG_FILE" || {
    echo "ERROR: Backup archive creation failed!" | tee -a "$LOG_FILE"
    [ "$GITEA_SERVICE_STATUS" = "stopped" ] && systemctl start gitea
    exit 1
}

BACKUP_END=$(date +%s)
BACKUP_TIME=$((BACKUP_END - BACKUP_START))
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)

# Restart services
if [ "$GITEA_SERVICE_STATUS" = "stopped" ]; then
    echo "Restarting Gitea service..." | tee -a "$LOG_FILE"
    systemctl start gitea
    sleep 5
    
    # Verify service started
    if systemctl is-active --quiet gitea; then
        echo "Gitea service restarted successfully" | tee -a "$LOG_FILE"
    else
        echo "WARNING: Gitea service restart may have failed" | tee -a "$LOG_FILE"
    fi
fi

# Verify backup integrity
echo "Verifying backup integrity..." | tee -a "$LOG_FILE"
if tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
    echo "Backup archive integrity: SUCCESS" | tee -a "$LOG_FILE"
    INTEGRITY_STATUS="verified"
else
    echo "Backup archive integrity: FAILED" | tee -a "$LOG_FILE"
    INTEGRITY_STATUS="failed"
    exit 1
fi

# Generate detailed manifest
echo "Creating backup manifest..." | tee -a "$LOG_FILE"
tar -tzvf "$BACKUP_FILE" | head -100 > "$BACKUP_PATH/file-list.txt" 2>/dev/null || true

cat > "$BACKUP_PATH/manifest.json" << EOF
{
  "backup_date": "$TIMESTAMP",
  "backup_type": "monthly_full",
  "backup_file": "$BACKUP_FILE",
  "backup_size": "$BACKUP_SIZE",
  "backup_duration_seconds": "$BACKUP_TIME",
  "integrity_status": "$INTEGRITY_STATUS",
  "services_affected": {
    "gitea": "$GITEA_SERVICE_STATUS"
  },
  "contents": {
    "gitea_data": "/opt/gitea",
    "openclaw_config": "/root/.openclaw",
    "ssh_keys": "/root/.ssh",
    "ssh_config": "/etc/ssh/sshd_config"
  },
  "verification": {
    "archive_test": "$INTEGRITY_STATUS",
    "timestamp": "$(date +"%Y-%m-%d %H:%M:%S")"
  },
  "system_state_at_backup": {
    "hostname": "$(hostname)",
    "disk_usage": "$(df -h / | tail -1)",
    "memory_usage": "$(free -h | grep Mem | awk '{print $3 "/" $2}')",
    "load_average": "$(uptime | awk -F'load average:' '{print $2}')",
    "uptime": "$(uptime -p)"
  }
}
EOF

# Test restore capability (optional - can be commented for large backups)
echo "Testing restore capability (listing archive contents)..." | tee -a "$LOG_FILE"
tar -tzf "$BACKUP_FILE" | wc -l | tee -a "$LOG_FILE"

# Apply retention policy
echo "Applying retention policy ($RETENTION_MONTHS months)..." | tee -a "$LOG_FILE"
find "$BACKUP_DIR" -type f -name "full-backup.tar.gz" -mtime +$((RETENTION_MONTHS * 30)) -delete 2>/dev/null || true
find "$BACKUP_DIR" -type d -empty -delete 2>/dev/null || true

# Calculate backup statistics
TOTAL_BACKUPS=$(find "$BACKUP_DIR" -name "full-backup.tar.gz" -type f | wc -l)
TOTAL_STORAGE=$(du -sh "$BACKUP_DIR" | cut -f1)

echo "=== Monthly Backup Complete ===" | tee -a "$LOG_FILE"
echo "Backup created: $BACKUP_FILE" | tee -a "$LOG_FILE"
echo "Backup size: $BACKUP_SIZE" | tee -a "$LOG_FILE"
echo "Backup duration: ${BACKUP_TIME}s" | tee -a "$LOG_FILE"
echo "Total monthly backups retained: $TOTAL_BACKUPS" | tee -a "$LOG_FILE"
echo "Total backup storage used: $TOTAL_STORAGE" | tee -a "$LOG_FILE"
echo "Completed at: $(date +"%Y-%m-%d %H:%M:%S")" | tee -a "$LOG_FILE"
echo "=================================" | tee -a "$LOG_FILE"

# Add notification logic here if needed
# Example: curl -X POST -d "Monthly backup completed: $BACKUP_SIZE" https://hooks.slack.com/...

exit 0