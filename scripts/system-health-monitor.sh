#!/bin/bash
# System Health Monitoring Script
# Usage: Run via cron every 15 minutes, logs to /var/log/system-health.log
# Alerts on: CPU > 90%, Memory > 90%, Disk > 85%, Service failures

LOG_FILE="/var/log/system-health.log"
THRESHOLD_CPU=90
THRESHOLD_MEMORY=90
THRESHOLD_DISK=85
SERVICES=("gitea" "fail2ban")
PORTS=("22" "3000")
EMAIL_ALERT=""  # Set to email address for alerts if configured
DISCORD_WEBHOOK=""  # Set to Discord webhook URL for alerts if configured

# Function to send alerts
send_alert() {
    local severity="$1"
    local message="$2"
    
    echo "[$(date)] [$severity] $message" >> "$LOG_FILE"
    
    # Email alert (if configured)
    if [ -n "$EMAIL_ALERT" ]; then
        echo -e "Subject: $severity Alert: System Health Monitor\n\n$message\nTime: $(date)\nHost: $(hostname)" | \
        sendmail "$EMAIL_ALERT"
    fi
    
    # Discord alert (if configured)
    if [ -n "$DISCORD_WEBHOOK" ]; then
        curl -H "Content-Type: application/json" \
             -d "{\"content\":\"**$severity Alert**: $message\nTime: $(date)\nHost: $(hostname)\"}" \
             "$DISCORD_WEBHOOK" >/dev/null 2>&1
    fi
}

echo "=== System Health Check $(date) ===" >> "$LOG_FILE"

# 1. CPU Usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d'.' -f1)
echo "CPU Usage: ${CPU_USAGE}%" >> "$LOG_FILE"
if [ "$CPU_USAGE" -gt "$THRESHOLD_CPU" ]; then
    send_alert "CRITICAL" "High CPU usage detected: ${CPU_USAGE}%"
fi

# 2. Memory Usage
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d'.' -f1)
echo "Memory Usage: ${MEMORY_USAGE}%" >> "$LOG_FILE"
if [ "$MEMORY_USAGE" -gt "$THRESHOLD_MEMORY" ]; then
    send_alert "CRITICAL" "High memory usage detected: ${MEMORY_USAGE}%"
fi

# 3. Disk Usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
echo "Disk Usage: ${DISK_USAGE}%" >> "$LOG_FILE"
if [ "$DISK_USAGE" -gt "$THRESHOLD_DISK" ]; then
    send_alert "WARNING" "High disk usage detected: ${DISK_USAGE}%"
fi

# 4. Swap Usage (if configured)
if [ -f /proc/swaps ] && grep -q swap /proc/swaps; then
    SWAP_USAGE=$(free | grep Swap | awk '{if ($2 != 0) print $3/$2 * 100.0; else print 0}' | cut -d'.' -f1)
    echo "Swap Usage: ${SWAP_USAGE}%" >> "$LOG_FILE"
    if [ "$SWAP_USAGE" -gt 50 ]; then
        send_alert "WARNING" "High swap usage detected: ${SWAP_USAGE}%"
    fi
fi

# 5. Service Status
for SERVICE in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$SERVICE"; then
        echo "Service $SERVICE: ACTIVE" >> "$LOG_FILE"
    else
        echo "Service $SERVICE: INACTIVE" >> "$LOG_FILE"
        send_alert "CRITICAL" "Service $SERVICE is not running!"
    fi
done

# 6. Port Availability
for PORT in "${PORTS[@]}"; do
    if ss -tln | grep -q ":$PORT "; then
        echo "Port $PORT: LISTENING" >> "$LOG_FILE"
    else
        echo "Port $PORT: NOT LISTENING" >> "$LOG_FILE"
        send_alert "CRITICAL" "Port $PORT is not listening!"
    fi
done

# 7. Load Average
LOAD_AVERAGE=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ')
CPU_CORES=$(nproc)
LOAD_THRESHOLD=$(echo "$CPU_CORES * 2" | bc)
if [ "$(echo "$LOAD_AVERAGE > $LOAD_THRESHOLD" | bc)" -eq 1 ]; then
    echo "Load Average: ${LOAD_AVERAGE} (Threshold: ${LOAD_THRESHOLD})" >> "$LOG_FILE"
    send_alert "WARNING" "High load average detected: $LOAD_AVERAGE"
else
    echo "Load Average: ${LOAD_AVERAGE} (OK)" >> "$LOG_FILE"
fi

# 8. Gitea Health Check
GITEA_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/healthz)
if [ "$GITEA_HEALTH" = "200" ]; then
    echo "Gitea Health Check: OK (HTTP $GITEA_HEALTH)" >> "$LOG_FILE"
else
    echo "Gitea Health Check: FAILED (HTTP $GITEA_HEALTH)" >> "$LOG_FILE"
    send_alert "CRITICAL" "Gitea health check failed with HTTP $GITEA_HEALTH"
fi

# 9. Backup Directory Check
BACKUP_DIR="/opt/gitea/data.backup"
if [ -d "$BACKUP_DIR" ]; then
    BACKUP_COUNT=$(find "$BACKUP_DIR" -type d -name "202*" | wc -l)
    LAST_BACKUP=$(find "$BACKUP_DIR" -type d -name "202*" -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)
    LAST_BACKUP_TIME=$(stat -c %Y "$LAST_BACKUP" 2>/dev/null || echo "0")
    CURRENT_TIME=$(date +%s)
    HOURS_SINCE=$(( (CURRENT_TIME - LAST_BACKUP_TIME) / 3600 ))
    
    echo "Backups: $BACKUP_COUNT found, last backup $HOURS_SINCE hours ago" >> "$LOG_FILE"
    
    if [ "$HOURS_SINCE" -gt 48 ]; then
        send_alert "WARNING" "Last backup was $HOURS_SINCE hours ago"
    fi
else
    echo "Backup Directory: NOT FOUND at $BACKUP_DIR" >> "$LOG_FILE"
    send_alert "CRITICAL" "Backup directory not found!"
fi

# 10. Log File Size Check (prevent disk filling)
LOG_SIZE=$(du -c /var/log/*.log 2>/dev/null | grep total | awk '{print $1}')
if [ "$LOG_SIZE" -gt 1000000 ]; then  # More than 1GB
    echo "Log file size: ${LOG_SIZE}KB (Large)" >> "$LOG_FILE"
    send_alert "WARNING" "Log files growing large: ${LOG_SIZE}KB"
fi

# 11. SSH Connection Check
SSH_CONNECTIONS=$(ss -tn src :22 | grep -v "State" | wc -l)
echo "SSH Connections: $SSH_CONNECTIONS" >> "$LOG_FILE"
if [ "$SSH_CONNECTIONS" -gt 20 ]; then
    send_alert "WARNING" "High SSH connection count: $SSH_CONNECTIONS"
fi

echo "=== Health Check Complete ===" >> "$LOG_FILE"

# Keep log file manageable (rotate if > 10MB)
if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt 10485760 ]; then
    mv "$LOG_FILE" "$LOG_FILE.old"
    gzip "$LOG_FILE.old"
fi