#!/bin/bash
# System Health Monitoring Script
# Location: /root/company-structure/scripts/system-health-monitor.sh
# Run via cron: */30 * * * * /root/company-structure/scripts/system-health-monitor.sh
# Monitors system health and alerts on thresholds

set -euo pipefail

# Configuration
LOG_FILE="/var/log/system-health.log"
ALERT_LOG="/var/log/system-alerts.log"
THRESHOLD_CPU=85        # Percentage
THRESHOLD_MEMORY=85     # Percentage  
THRESHOLD_DISK=85       # Percentage
THRESHOLD_SWAP=70       # Percentage
CHECK_INTERVAL=30       # Minutes between checks

# Alert Levels
ALERT_CRITICAL="🔴 CRITICAL"
ALERT_WARNING="🟡 WARNING"
ALERT_INFO="🔵 INFO"
ALERT_OK="🟢 OK"

# Colors for output (optional)
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "=== System Health Check $TIMESTAMP ===" | tee -a "$LOG_FILE"

# Initialize alert array
declare -a ALERTS=()
declare -a WARNINGS=()
declare -a OK_STATUS=()

# 1. CPU Usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d'.' -f1)
CPU_STATUS="$ALERT_OK"
if [ "$CPU_USAGE" -gt "$THRESHOLD_CPU" ]; then
    CPU_STATUS="$ALERT_CRITICAL"
    ALERTS+=("CPU usage: ${CPU_USAGE}% (threshold: ${THRESHOLD_CPU}%)")
elif [ "$CPU_USAGE" -gt "70" ]; then
    CPU_STATUS="$ALERT_WARNING"
    WARNINGS+=("CPU usage: ${CPU_USAGE}% (threshold: ${THRESHOLD_CPU}%)")
else
    OK_STATUS+=("CPU usage: ${CPU_USAGE}%")
fi
echo "$CPU_STATUS CPU Usage: ${CPU_USAGE}%" | tee -a "$LOG_FILE"

# 2. Memory Usage
MEMORY_TOTAL=$(free -m | grep Mem | awk '{print $2}')
MEMORY_USED=$(free -m | grep Mem | awk '{print $3}')
MEMORY_PERCENT=$((MEMORY_USED * 100 / MEMORY_TOTAL))
MEMORY_STATUS="$ALERT_OK"
if [ "$MEMORY_PERCENT" -gt "$THRESHOLD_MEMORY" ]; then
    MEMORY_STATUS="$ALERT_CRITICAL"
    ALERTS+=("Memory usage: ${MEMORY_PERCENT}% (${MEMORY_USED}/${MEMORY_TOTAL}MB)")
elif [ "$MEMORY_PERCENT" -gt "70" ]; then
    MEMORY_STATUS="$ALERT_WARNING"
    WARNINGS+=("Memory usage: ${MEMORY_PERCENT}% (${MEMORY_USED}/${MEMORY_TOTAL}MB)")
else
    OK_STATUS+=("Memory usage: ${MEMORY_PERCENT}%")
fi
echo "$MEMORY_STATUS Memory Usage: ${MEMORY_PERCENT}% (${MEMORY_USED}/${MEMORY_TOTAL}MB)" | tee -a "$LOG_FILE"

# 3. Disk Usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
DISK_STATUS="$ALERT_OK"
if [ "$DISK_USAGE" -gt "$THRESHOLD_DISK" ]; then
    DISK_STATUS="$ALERT_CRITICAL"
    ALERTS+=("Disk usage: ${DISK_USAGE}% (threshold: ${THRESHOLD_DISK}%)")
elif [ "$DISK_USAGE" -gt "70" ]; then
    DISK_STATUS="$ALERT_WARNING"
    WARNINGS+=("Disk usage: ${DISK_USAGE}%")
else
    OK_STATUS+=("Disk usage: ${DISK_USAGE}%")
fi
echo "$DISK_STATUS Disk Usage: ${DISK_USAGE}%" | tee -a "$LOG_FILE"

# 4. Swap Usage (check if swap exists)
if swapon --show > /dev/null 2>&1; then
    SWAP_TOTAL=$(free -m | grep Swap | awk '{print $2}')
    if [ "$SWAP_TOTAL" -gt "0" ]; then
        SWAP_USED=$(free -m | grep Swap | awk '{print $3}')
        SWAP_PERCENT=$((SWAP_USED * 100 / SWAP_TOTAL))
        SWAP_STATUS="$ALERT_OK"
        if [ "$SWAP_PERCENT" -gt "$THRESHOLD_SWAP" ]; then
            SWAP_STATUS="$ALERT_WARNING"
            WARNINGS+=("Swap usage: ${SWAP_PERCENT}% (${SWAP_USED}/${SWAP_TOTAL}MB)")
        else
            OK_STATUS+=("Swap usage: ${SWAP_PERCENT}%")
        fi
        echo "$SWAP_STATUS Swap Usage: ${SWAP_PERCENT}% (${SWAP_USED}/${SWAP_TOTAL}MB)" | tee -a "$LOG_FILE"
    else
        echo "$ALERT_INFO No swap configured" | tee -a "$LOG_FILE"
    fi
else
    echo "$ALERT_INFO No swap configured" | tee -a "$LOG_FILE"
fi

# 5. Service Status
echo "" | tee -a "$LOG_FILE"
echo "=== Service Status ===" | tee -a "$LOG_FILE"

SERVICES=(
    "gitea:Gitea"
    "ssh:SSH"
    "openclaw-gateway:OpenClaw Gateway"
    "fail2ban:Fail2Ban"
    "ufw:UFW Firewall"
)

for SERVICE in "${SERVICES[@]}"; do
    SERVICE_NAME=${SERVICE%:*}
    DISPLAY_NAME=${SERVICE#*:}
    
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        echo "$ALERT_OK ${DISPLAY_NAME}: ACTIVE" | tee -a "$LOG_FILE"
        OK_STATUS+=("${DISPLAY_NAME} service: active")
    else
        echo "$ALERT_CRITICAL ${DISPLAY_NAME}: INACTIVE" | tee -a "$LOG_FILE"
        ALERTS+=("${DISPLAY_NAME} service: inactive")
    fi
done

# 6. Port Availability
echo "" | tee -a "$LOG_FILE"
echo "=== Port Monitoring ===" | tee -a "$LOG_FILE"

PORTS=(
    "22:SSH"
    "3000:Gitea"
    "3002:Nuxt Dev Server"
    "8880:DeepInfra Proxy"
    "18789:OpenClaw Gateway"
)

for PORT in "${PORTS[@]}"; do
    PORT_NUM=${PORT%:*}
    PORT_NAME=${PORT#*:}
    
    if ss -tln | grep -q ":$PORT_NUM "; then
        echo "$ALERT_OK ${PORT_NAME} (${PORT_NUM}/tcp): LISTENING" | tee -a "$LOG_FILE"
        OK_STATUS+=("Port ${PORT_NUM}: listening")
    else
        echo "$ALERT_WARNING ${PORT_NAME} (${PORT_NUM}/tcp): NOT LISTENING" | tee -a "$LOG_FILE"
        WARNINGS+=("Port ${PORT_NUM}: not listening")
    fi
done

# 7. Network Connectivity Check
echo "" | tee -a "$LOG_FILE"
echo "=== Network Connectivity ===" | tee -a "$LOG_FILE"

if ping -c 2 -W 1 8.8.8.8 > /dev/null 2>&1; then
    echo "$ALERT_OK Internet connectivity: OK" | tee -a "$LOG_FILE"
    OK_STATUS+=("Internet connectivity: OK")
else
    echo "$ALERT_WARNING Internet connectivity: FAILED" | tee -a "$LOG_FILE"
    WARNINGS+=("Internet connectivity: failed")
fi

# 8. Load Average
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | xargs)
LOAD_1=$(echo "$LOAD_AVG" | awk -F',' '{print $1}' | xargs)
LOAD_5=$(echo "$LOAD_AVG" | awk -F',' '{print $2}' | xargs)
LOAD_15=$(echo "$LOAD_AVG" | awk -F',' '{print $3}' | xargs)

echo "$ALERT_INFO Load Average: $LOAD_AVG" | tee -a "$LOG_FILE"
echo "$ALERT_INFO Uptime: $(uptime -p)" | tee -a "$LOG_FILE"

# 9. Security Checks
echo "" | tee -a "$LOG_FILE"
echo "=== Security Checks ===" | tee -a "$LOG_FILE"

# Check for failed SSH attempts
FAILED_SSH=$(grep "Failed password\|authentication failure" /var/log/auth.log 2>/dev/null | tail -5 | wc -l)
if [ "$FAILED_SSH" -gt "10" ]; then
    echo "$ALERT_WARNING SSH failures: $FAILED_SSH (last 5 entries)" | tee -a "$LOG_FILE"
    WARNINGS+=("SSH failures: $FAILED_SSH")
else
    echo "$ALERT_OK SSH failures: $FAILED_SSH (last 5 entries)" | tee -a "$LOG_FILE"
    OK_STATUS+=("SSH failures: normal")
fi

# Check for root login attempts
ROOT_LOGINS=$(last root | head -10 | wc -l)
echo "$ALERT_INFO Recent root logins: $ROOT_LOGINS" | tee -a "$LOG_FILE"

# Summary Section
echo "" | tee -a "$LOG_FILE"
echo "=== Health Summary ===" | tee -a "$LOG_FILE"

if [ ${#ALERTS[@]} -gt 0 ]; then
    echo "$ALERT_CRITICAL Critical Issues Found:" | tee -a "$LOG_FILE"
    for alert in "${ALERTS[@]}"; do
        echo "  • $alert" | tee -a "$LOG_FILE"
    done
    
    # Log to alert log
    echo "[$TIMESTAMP] CRITICAL ALERTS:" >> "$ALERT_LOG"
    for alert in "${ALERTS[@]}"; do
        echo "  • $alert" >> "$ALERT_LOG"
    done
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "$ALERT_WARNING Warnings:" | tee -a "$LOG_FILE"
    for warning in "${WARNINGS[@]}"; do
        echo "  • $warning" | tee -a "$LOG_FILE"
    done
fi

if [ ${#OK_STATUS[@]} -gt 0 ]; then
    echo "$ALERT_OK All systems normal:" | tee -a "$LOG_FILE"
    for ok in "${OK_STATUS[@]}"; do
        echo "  • $ok" | tee -a "$LOG_FILE"
    done
fi

# Send notifications if critical alerts exist
if [ ${#ALERTS[@]} -gt 0 ]; then
    # Notification logic could be added here
    # Example: Send Discord/Telegram alert
    echo "Sending critical alerts notification..." | tee -a "$LOG_FILE"
    # curl -X POST -H "Content-Type: application/json" -d '{"text":"Critical system alerts detected"}' https://hooks.slack.com/...
fi

echo "=== Check Complete ===" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Return exit code based on alerts
if [ ${#ALERTS[@]} -gt 0 ]; then
    exit 1
elif [ ${#WARNINGS[@]} -gt 0 ]; then
    exit 2
else
    exit 0
fi