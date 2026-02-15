#!/bin/bash
#
# Security Verification Script
# Version: 1.0
# Date: February 15, 2026
#
# Purpose: Verify security implementation status and identify gaps
# Usage: Run as root or with sudo permissions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then 
        log_error "Please run as root (use sudo)"
        exit 1
    fi
}

print_header() {
    echo "================================================"
    echo " $1"
    echo "================================================"
    echo ""
}

# Main verification function
verify_security() {
    print_header "Security Implementation Verification"
    log_info "Running verification checks..."
    echo ""
    
    # Section 1: Firewall Verification
    print_header "1. Firewall Verification"
    
    # Check UFW installation
    if command -v ufw >/dev/null 2>&1; then
        log_success "UFW installed"
        
        # Check UFW status
        if ufw status | grep -q "Status: active"; then
            log_success "UFW firewall active"
            
            # Check rules
            echo "Current UFW rules:"
            ufw status numbered | grep -E "^\[" | head -20
            
            # Check critical ports
            PORT_22=$(ufw status | grep "22/tcp" | grep -c "ALLOW")
            PORT_3000=$(ufw status | grep "3000/tcp" | grep -c "ALLOW")
            PORT_3002=$(ufw status | grep "3002/tcp" | grep -c "DENY")
            PORT_8880=$(ufw status | grep "8880/tcp" | grep -c "DENY")
            
            if [ "$PORT_22" -eq 1 ]; then
                log_success "Port 22 (SSH) is allowed"
            else
                log_warning "Port 22 (SSH) may not be properly configured"
            fi
            
            if [ "$PORT_3000" -eq 1 ]; then
                log_success "Port 3000 (Gitea) is allowed"
            else
                log_warning "Port 3000 (Gitea) may not be properly configured"
            fi
            
            if [ "$PORT_3002" -eq 1 ] || [ "$PORT_3002" -eq 0 ]; then
                log_info "Port 3002 is not accessible externally (good)"
            else
                log_warning "Port 3002 should be denied or restricted"
            fi
            
            if [ "$PORT_8880" -eq 1 ] || [ "$PORT_8880" -eq 0 ]; then
                log_info "Port 8880 is not accessible externally (good)"
            else
                log_warning "Port 8880 should be denied or restricted"
            fi
        else
            log_error "UFW firewall not active"
        fi
    else
        log_error "UFW not installed"
    fi
    
    # Check iptables
    if command -v iptables >/dev/null 2>&1; then
        log_success "iptables available"
        echo "iptables rules count: $(iptables -L -n | wc -l)"
    fi
    
    echo ""
    
    # Section 2: SSH Hardening Verification
    print_header "2. SSH Hardening Verification"
    
    SSH_CONFIG="/etc/ssh/sshd_config"
    if [ -f "$SSH_CONFIG" ]; then
        log_success "SSH configuration file exists"
        
        # Check critical settings
        PERMIT_ROOT=$(grep -i "^PermitRootLogin" "$SSH_CONFIG" | tail -1)
        PASSWORD_AUTH=$(grep -i "^PasswordAuthentication" "$SSH_CONFIG" | tail -1)
        MAX_AUTH_TRIES=$(grep -i "^MaxAuthTries" "$SSH_CONFIG" | tail -1)
        PROTOCOL=$(grep -i "^Protocol" "$SSH_CONFIG" | tail -1)
        
        echo "SSH Configuration:"
        echo "  PermitRootLogin: $PERMIT_ROOT"
        echo "  PasswordAuthentication: $PASSWORD_AUTH"
        echo "  MaxAuthTries: $MAX_AUTH_TRIES"
        echo "  Protocol: $PROTOCOL"
        echo ""
        
        # Evaluate settings
        if [[ "$PERMIT_ROOT" =~ no ]]; then
            log_success "Root login disabled (secure)"
        else
            log_error "Root login may be enabled (insecure)"
        fi
        
        if [[ "$PASSWORD_AUTH" =~ no ]]; then
            log_success "Password authentication disabled (key-only)"
        else
            log_warning "Password authentication may be enabled"
        fi
        
        if [[ "$MAX_AUTH_TRIES" =~ ^MaxAuthTries\ +[0-9] ]]; then
            log_success "Max authentication attempts configured"
        else
            log_warning "Max authentication attempts not configured"
        fi
        
        if [[ "$PROTOCOL" =~ ^Protocol\ +2 ]]; then
            log_success "SSH Protocol 2 enforced"
        elif [[ "$PROTOCOL" =~ ^Protocol\ +2,1 ]]; then
            log_warning "SSH Protocol 1 enabled (deprecated)"
        else
            log_warning "SSH Protocol not explicitly configured"
        fi
    else
        log_error "SSH configuration file not found"
    fi
    
    # Check SSH service status
    if systemctl is-active sshd >/dev/null 2>&1; then
        log_success "SSH service is active"
    else
        log_error "SSH service is not active"
    fi
    
    echo ""
    
    # Section 3: Fail2Ban Verification
    print_header "3. Fail2Ban Verification"
    
    if command -v fail2ban-client >/dev/null 2>&1; then
        log_success "Fail2Ban installed"
        
        # Check Fail2Ban service status
        if systemctl is-active fail2ban >/dev/null 2>&1; then
            log_success "Fail2Ban service is active"
            
            # Check SSH jail status
            if fail2ban-client status sshd >/dev/null 2>&1; then
                log_success "Fail2Ban SSH jail active"
                echo "SSH jail status:"
                fail2ban-client status sshd | grep -A5 "Status for the jail:" | tail -5
                
                # Check banned IPs
                BANNED_IPS=$(fail2ban-client status sshd | grep -i "banned" | awk '{print $4}')
                if [ "$BANNED_IPS" -gt 0 ] 2>/dev/null; then
                    log_info "$BANNED_IPS IPs currently banned from SSH"
                else
                    log_info "No IPs currently banned from SSH"
                fi
            else
                log_warning "Fail2Ban SSH jail not configured"
            fi
        else
            log_error "Fail2Ban service is not active"
        fi
    else
        log_error "Fail2Ban not installed"
    fi
    
    # Check SSH auth logs
    echo ""
    echo "Recent SSH authentication failures:"
    grep -i "fail\|invalid\|refused" /var/log/auth.log | tail -5 || log_warning "No authentication failures found"
    
    echo ""
    
    # Section 4: Service Security Verification
    print_header "4. Service Security Verification"
    
    log_info "Checking listening services..."
    
    # Check what's listening on public interfaces
    echo "Services listening on all interfaces (0.0.0.0):"
    ss -tlnp | grep -E '0\.0\.0\.0:|:::' | grep -E ':(22|3000|3001|3002|8880)' || log_info "No services listening on 0.0.0.0"
    
    echo ""
    echo "Services listening on localhost only (127.0.0.1):"
    ss -tlnp | grep -E '127\.0\.0\.1:|::1' | grep -E ':(22|3000|3001|3002|8880)' || log_info "No services listening on 127.0.0.1"
    
    echo ""
    echo "Total services on key ports:"
    ss -tlnp | grep -E ':(22|3000|3001|3002|8880)' | wc -l
    
    # Check Gitea service
    if systemctl is-active gitea >/dev/null 2>&1; then
        log_success "Gitea service is active"
        GITEA_PORT=$(ss -tlnp | grep gitea | grep -o ':3000' | wc -l)
        if [ "$GITEA_PORT" -gt 0 ]; then
            log_success "Gitea listening on port 3000"
        else
            log_error "Gitea not listening on expected port"
        fi
    else
        log_warning "Gitea service is not active"
    fi
    
    echo ""
    
    # Section 5: Logging Verification
    print_header "5. Logging Verification"
    
    # Check rsyslog
    if systemctl is-active rsyslog >/dev/null 2>&1; then
        log_success "rsyslog service is active"
    else
        log_warning "rsyslog service is not active"
    fi
    
    # Check log files exist
    LOG_FILES="/var/log/auth.log /var/log/syslog /var/log/kern.log"
    for LOG_FILE in $LOG_FILES; do
        if [ -f "$LOG_FILE" ]; then
            log_success "$LOG_FILE exists"
            echo "  Size: $(ls -lh "$LOG_FILE" | awk '{print $5}')"
            echo "  Last modified: $(stat -c %y "$LOG_FILE")"
        else
            log_warning "$LOG_FILE does not exist"
        fi
    done
    
    # Check log rotation
    if [ -f "/etc/logrotate.d/rsyslog" ]; then
        log_success "rsyslog logrotate configuration exists"
    else
        log_warning "rsyslog logrotate configuration missing"
    fi
    
    echo ""
    
    # Section 6: Backup System Verification
    print_header "6. Backup System Verification"
    
    # Check backup scripts
    BACKUP_SCRIPTS="/root/company-structure/scripts/daily-backup.sh /root/company-structure/scripts/monthly-backup.sh /root/company-structure/scripts/comprehensive-backup.sh"
    for SCRIPT in $BACKUP_SCRIPTS; do
        if [ -f "$SCRIPT" ]; then
            log_success "$SCRIPT exists"
            if [ -x "$SCRIPT" ]; then
                log_success "  Script is executable"
            else
                log_warning "  Script is not executable (run: chmod +x $SCRIPT)"
            fi
        else
            log_error "$SCRIPT does not exist"
        fi
    done
    
    # Check backup directories
    BACKUP_DIRS="/var/backups/company-structure /var/backups/company-structure/daily /var/backups/company-structure/monthly /opt/gitea/data.backup"
    for DIR in $BACKUP_DIRS; do
        if [ -d "$DIR" ]; then
            log_success "$DIR exists"
            echo "  Contents: $(ls "$DIR" | wc -l) files"
        else
            log_warning "$DIR does not exist"
        fi
    done
    
    # Check cron jobs
    echo ""
    echo "Cron jobs for backups:"
    crontab -l | grep -E "backup|daily|monthly" || log_warning "No backup cron jobs found"
    
    echo ""
    
    # Section 7: Health Monitoring Verification
    print_header "7. Health Monitoring Verification"
    
    # Check health monitoring script
    HEALTH_SCRIPT="/root/company-structure/scripts/system-health-monitor.sh"
    if [ -f "$HEALTH_SCRIPT" ]; then
        log_success "Health monitoring script exists"
        if [ -x "$HEALTH_SCRIPT" ]; then
            log_success "  Script is executable"
        else
            log_warning "  Script is not executable"
        fi
    else
        log_error "Health monitoring script does not exist"
    fi
    
    # Check health monitoring cron
    echo ""
    echo "Cron jobs for health monitoring:"
    crontab -l | grep -E "health-monitor|system-health" || log_warning "No health monitoring cron jobs found"
    
    # Check recent health logs
    HEALTH_LOG="/var/log/company-structure/health-monitor.log"
    if [ -f "$HEALTH_LOG" ]; then
        log_success "Health log exists"
        echo "  Last 5 entries:"
        tail -5 "$HEALTH_LOG"
    else
        log_warning "Health log does not exist"
    fi
    
    echo ""
    
    # Section 8: Financial Tracking Verification
    print_header "8. Financial Tracking Verification"
    
    # Check finance script
    FINANCE_SCRIPT="/root/company-structure/scripts/finance-daily.sh"
    if [ -f "$FINANCE_SCRIPT" ]; then
        log_success "Finance daily script exists"
        if [ -x "$FINANCE_SCRIPT" ]; then
            log_success "  Script is executable"
        else
            log_warning "  Script is not executable"
        fi
    else
        log_error "Finance daily script does not exist"
    fi
    
    # Check finance directory
    FINANCE_DIR="/root/company-structure/finance"
    if [ -d "$FINANCE_DIR" ]; then
        log_success "Finance directory exists"
        echo "  Files in directory:"
        ls -la "$FINANCE_DIR"
    else
        log_warning "Finance directory does not exist"
    fi
    
    # Check finance cron
    echo ""
    echo "Cron jobs for finance:"
    crontab -l | grep -E "finance-daily" || log_warning "No finance cron jobs found"
    
    echo ""
    
    # Section 9: System Resources Check
    print_header "9. System Resources Check"
    
    log_info "System resource overview:"
    
    # CPU usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    if [ -z "$CPU_USAGE" ]; then
        CPU_USAGE=$(top -bn1 | grep "%Cpu" | awk '{print $2 + $4}')
    fi
    echo "CPU Usage: ${CPU_USAGE}%"
    
    if [ "$(echo "$CPU_USAGE" | cut -d. -f1)" -gt 80 ]; then
        log_warning "High CPU usage detected"
    else
        log_success "CPU usage normal"
    fi
    
    # Memory usage
    MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    echo "Memory Usage: ${MEM_USAGE}%"
    
    if [ "$MEM_USAGE" -gt 90 ]; then
        log_warning "High memory usage detected"
    else
        log_success "Memory usage normal"
    fi
    
    # Disk usage
    DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "Disk Usage: ${DISK_USAGE}%"
    
    if [ "$DISK_USAGE" -gt 85 ]; then
        log_warning "High disk usage detected"
    else
        log_success "Disk usage normal"
    fi
    
    # Uptime
    UPTIME=$(uptime -p)
    echo "Uptime: $UPTIME"
    
    echo ""
    
    # Section 10: Security Summary
    print_header "10. Security Implementation Summary"
    
    echo "Implementation Status:"
    echo "----------------------"
    
    # Count successes and warnings
    SUCCESS_COUNT=$(grep -c "SUCCESS" <<< "$VERIFICATION_OUTPUT")
    WARNING_COUNT=$(grep -c "WARNING" <<< "$VERIFICATION_OUTPUT")
    ERROR_COUNT=$(grep -c "ERROR" <<< "$VERIFICATION_OUTPUT")
    
    echo "✅ Successes: $SUCCESS_COUNT"
    echo "⚠️  Warnings: $WARNING_COUNT"
    echo "❌ Errors: $ERROR_COUNT"
    
    echo ""
    
    if [ "$ERROR_COUNT" -eq 0 ]; then
        if [ "$WARNING_COUNT" -eq 0 ]; then
            log_success "All security checks passed!"
        else
            log_warning "Security checks passed with $WARNING_COUNT warnings"
        fi
    else
        log_error "Security checks failed with $ERROR_COUNT errors"
    fi
    
    echo ""
    echo "Recommended Actions:"
    echo "-------------------"
    
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "1. Fix all ERROR items first"
        grep "ERROR" <<< "$VERIFICATION_OUTPUT" | head -5
    fi
    
    if [ "$WARNING_COUNT" -gt 0 ]; then
        echo "2. Address WARNING items"
        grep "WARNING" <<< "$VERIFICATION_OUTPUT" | head -5
    fi
    
    if [ "$ERROR_COUNT" -eq 0 ] && [ "$WARNING_COUNT" -eq 0 ]; then
        echo "All security measures are properly implemented!"
        echo "Continue with regular monitoring and maintenance."
    fi
}

# Main execution
main() {
    check_root
    
    # Create log directory if it doesn't exist
    mkdir -p /var/log/company-structure/
    
    # Run verification and capture output
    VERIFICATION_OUTPUT=$(verify_security 2>&1)
    
    # Save to log file
    LOG_FILE="/var/log/company-structure/security-verification-$(date +%Y%m%d-%H%M%S).log"
    echo "$VERIFICATION_OUTPUT" > "$LOG_FILE"
    
    # Display summary
    echo ""
    print_header "Verification Complete"
    echo "Detailed output saved to: $LOG_FILE"
    echo ""
    echo "To view the full report:"
    echo "  cat $LOG_FILE"
    echo ""
    echo "To fix identified issues, refer to:"
    echo "  /root/company-structure/IMPLEMENTATION_GUIDE.md"
    echo ""
    
    # Return exit code based on errors
    if echo "$VERIFICATION_OUTPUT" | grep -q "ERROR"; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"