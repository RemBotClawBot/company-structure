#!/bin/bash
#
# Backup Verification Script
# Version: 1.0
# Date: February 15, 2026
#
# Purpose: Verify backup system integrity and functionality
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

verify_backup_system() {
    print_header "Backup System Verification"
    
    # Section 1: Backup Scripts Verification
    print_header "1. Backup Scripts Verification"
    
    BACKUP_SCRIPTS=(
        "/root/company-structure/scripts/daily-backup.sh"
        "/root/company-structure/scripts/monthly-backup.sh"
        "/root/company-structure/scripts/comprehensive-backup.sh"
    )
    
    for SCRIPT in "${BACKUP_SCRIPTS[@]}"; do
        if [ -f "$SCRIPT" ]; then
            log_success "$SCRIPT exists"
            
            # Check if executable
            if [ -x "$SCRIPT" ]; then
                log_success "  Script is executable"
            else
                log_warning "  Script is not executable (run: chmod +x $SCRIPT)"
            fi
            
            # Check script permissions
            PERMISSIONS=$(stat -c "%A" "$SCRIPT")
            echo "  Permissions: $PERMISSIONS"
            
            # Check script owner
            OWNER=$(stat -c "%U:%G" "$SCRIPT")
            echo "  Owner: $OWNER"
        else
            log_error "$SCRIPT does not exist"
        fi
    done
    
    echo ""
    
    # Section 2: Backup Directories Verification
    print_header "2. Backup Directories Verification"
    
    BACKUP_DIRS=(
        "/var/backups/company-structure"
        "/var/backups/company-structure/daily"
        "/var/backups/company-structure/monthly"
        "/opt/gitea/data.backup"
        "/var/backups/finance"
    )
    
    for DIR in "${BACKUP_DIRS[@]}"; do
        if [ -d "$DIR" ]; then
            log_success "$DIR exists"
            
            # Check directory permissions
            PERMISSIONS=$(stat -c "%A" "$DIR")
            echo "  Permissions: $PERMISSIONS"
            
            # Check disk space
            DISK_USAGE=$(du -sh "$DIR" 2>/dev/null | awk '{print $1}' || echo "Unknown")
            echo "  Disk usage: $DISK_USAGE"
            
            # Count files
            FILE_COUNT=$(find "$DIR" -type f | wc -l)
            echo "  File count: $FILE_COUNT"
            
            # List recent backups
            if [ "$FILE_COUNT" -gt 0 ]; then
                echo "  Recent files:"
                ls -lt "$DIR" | head -5 | awk 'NR>1 {print "    "$NF}'
            fi
        else
            log_warning "$DIR does not exist"
        fi
    done
    
    echo ""
    
    # Section 3: Cron Job Verification
    print_header "3. Cron Job Verification"
    
    log_info "Checking cron jobs for backup automation..."
    
    CRON_JOBS=$(crontab -l 2>/dev/null || echo "")
    
    if echo "$CRON_JOBS" | grep -q "daily-backup.sh"; then
        log_success "Daily backup cron job configured"
        echo "$CRON_JOBS" | grep "daily-backup.sh"
    else
        log_warning "Daily backup cron job not configured"
    fi
    
    if echo "$CRON_JOBS" | grep -q "monthly-backup.sh"; then
        log_success "Monthly backup cron job configured"
        echo "$CRON_JOBS" | grep "monthly-backup.sh"
    else
        log_warning "Monthly backup cron job not configured"
    fi
    
    if echo "$CRON_JOBS" | grep -q "comprehensive-backup.sh"; then
        log_success "Comprehensive backup cron job configured"
        echo "$CRON_JOBS" | grep "comprehensive-backup.sh"
    else
        log_info "Comprehensive backup cron job not configured (usually run manually)"
    fi
    
    echo ""
    
    # Section 4: Backup Log Verification
    print_header "4. Backup Log Verification"
    
    LOG_DIR="/var/log/company-structure"
    if [ -d "$LOG_DIR" ]; then
        log_success "Log directory exists"
        
        LOG_FILES=(
            "$LOG_DIR/backup-daily.log"
            "$LOG_DIR/backup-monthly.log"
            "$LOG_DIR/backup-comprehensive.log"
        )
        
        for LOG_FILE in "${LOG_FILES[@]}"; do
            if [ -f "$LOG_FILE" ]; then
                log_success "$LOG_FILE exists"
                
                # Check log size
                LOG_SIZE=$(ls -lh "$LOG_FILE" | awk '{print $5}')
                echo "  Size: $LOG_SIZE"
                
                # Check last modification
                LOG_MOD=$(stat -c "%y" "$LOG_FILE")
                echo "  Last modified: $LOG_MOD"
                
                # Show last 3 lines
                echo "  Last 3 entries:"
                tail -3 "$LOG_FILE" | sed 's/^/    /'
            else
                log_warning "$LOG_FILE does not exist"
            fi
        done
    else
        log_warning "Log directory does not exist"
    fi
    
    echo ""
    
    # Section 5: Backup Contents Verification
    print_header "5. Backup Contents Verification"
    
    # Find latest backup
    LATEST_BACKUP=$(find /var/backups/company-structure -name "*.tar.gz" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")
    
    if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
        log_success "Latest backup found: $(basename "$LATEST_BACKUP")"
        
        # Check backup size
        BACKUP_SIZE=$(ls -lh "$LATEST_BACKUP" | awk '{print $5}')
        echo "  Size: $BACKUP_SIZE"
        
        # Check backup age
        BACKUP_AGE=$(find "$LATEST_BACKUP" -mtime -1 2>/dev/null)
        if [ -n "$BACKUP_AGE" ]; then
            log_success "  Backup is recent (less than 1 day old)"
        else
            log_warning "  Backup is older than 1 day"
        fi
        
        # Test backup integrity
        log_info "  Testing backup integrity..."
        if tar -tzf "$LATEST_BACKUP" >/dev/null 2>&1; then
            log_success "  Backup integrity check passed"
            
            # List some contents
            echo "  Sample contents:"
            tar -tzf "$LATEST_BACKUP" | head -10 | sed 's/^/    /'
        else
            log_error "  Backup integrity check failed"
        fi
    else
        log_warning "No backup files found"
    fi
    
    echo ""
    
    # Section 6: Gitea Data Backup Verification
    print_header "6. Gitea Data Backup Verification"
    
    GITEA_BACKUP_DIR="/opt/gitea/data.backup"
    if [ -d "$GITEA_BACKUP_DIR" ]; then
        log_success "Gitea backup directory exists"
        
        # Count files
        GITEA_FILE_COUNT=$(find "$GITEA_BACKUP_DIR" -type f | wc -l)
        echo "  File count: $GITEA_FILE_COUNT"
        
        # Check total size
        GITEA_SIZE=$(du -sh "$GITEA_BACKUP_DIR" | awk '{print $1}')
        echo "  Total size: $GITEA_SIZE"
        
        # Check recent backups
        echo "  Recent backups:"
        ls -lt "$GITEA_BACKUP_DIR" | head -5 | awk 'NR>1 {print "    "$NF}'
        
        # Check for critical Gitea files
        CRITICAL_FILES=(
            "app.ini"
            "gitea.db"
            "custom"
        )
        
        for FILE in "${CRITICAL_FILES[@]}"; do
            if [ -e "$GITEA_BACKUP_DIR/$FILE" ]; then
                log_success "  Critical file exists: $FILE"
            else
                log_warning "  Critical file missing: $FILE"
            fi
        done
    else
        log_error "Gitea backup directory does not exist"
    fi
    
    echo ""
    
    # Section 7: Financial Backup Verification
    print_header "7. Financial Backup Verification"
    
    FINANCE_DIR="/root/company-structure/finance"
    FINANCE_BACKUP_DIR="/var/backups/finance"
    
    if [ -d "$FINANCE_DIR" ]; then
        log_success "Finance directory exists"
        
        # Count finance files
        FINANCE_FILES=$(find "$FINANCE_DIR" -name "*.md" -type f | wc -l)
        echo "  Finance files: $FINANCE_FILES"
        
        if [ "$FINANCE_FILES" -gt 0 ]; then
            log_success "  Finance data present"
            
            # Show latest finance file
            LATEST_FINANCE=$(ls -t "$FINANCE_DIR"/*.md 2>/dev/null | head -1)
            if [ -n "$LATEST_FINANCE" ]; then
                echo "  Latest finance file: $(basename "$LATEST_FINANCE")"
                echo "  Last modified: $(stat -c "%y" "$LATEST_FINANCE")"
            fi
        else
            log_warning "  No finance files found"
        fi
    else
        log_error "Finance directory does not exist"
    fi
    
    if [ -d "$FINANCE_BACKUP_DIR" ]; then
        log_success "Finance backup directory exists"
        
        # Count backup files
        FINANCE_BACKUPS=$(find "$FINANCE_BACKUP_DIR" -name "*.tar.gz" -type f | wc -l)
        echo "  Finance backups: $FINANCE_BACKUPS"
    else
        log_warning "Finance backup directory does not exist"
    fi
    
    echo ""
    
    # Section 8: Backup Summary
    print_header "8. Backup System Summary"
    
    echo "Backup Status Overview:"
    echo "-----------------------"
    
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
            log_success "Backup system is fully operational!"
        else
            log_warning "Backup system operational with $WARNING_COUNT warnings"
        fi
    else
        log_error "Backup system has $ERROR_COUNT critical errors"
    fi
    
    echo ""
    echo "Recommendations:"
    echo "----------------"
    
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "1. Fix all ERROR items immediately"
        echo "2. Ensure backup scripts are executable"
        echo "3. Create missing directories"
        grep "ERROR" <<< "$VERIFICATION_OUTPUT" | head -3
    fi
    
    if [ "$WARNING_COUNT" -gt 0 ]; then
        echo "2. Address WARNING items"
        echo "3. Configure cron jobs if missing"
        echo "4. Test backup restoration"
        grep "WARNING" <<< "$VERIFICATION_OUTPUT" | head -3
    fi
    
    if [ "$ERROR_COUNT" -eq 0 ] && [ "$WARNING_COUNT" -eq 0 ]; then
        echo "1. Continue regular backup monitoring"
        echo "2. Test restore procedures quarterly"
        echo "3. Review backup retention policies monthly"
    fi
    
    echo ""
    echo "Next Steps:"
    echo "-----------"
    echo "1. Run backup scripts manually to test:"
    echo "   /root/company-structure/scripts/daily-backup.sh --dry-run"
    echo "   /root/company-structure/scripts/monthly-backup.sh --dry-run"
    echo ""
    echo "2. Schedule regular backup tests:"
    echo "   Add to crontab: 0 4 * * 0 /root/company-structure/scripts/backup-verify.sh"
    echo ""
    echo "3. Monitor backup logs:"
    echo "   tail -f /var/log/company-structure/backup-*.log"
}

# Main execution
main() {
    check_root
    
    # Create log directory if it doesn't exist
    mkdir -p /var/log/company-structure/
    
    # Run verification and capture output
    VERIFICATION_OUTPUT=$(verify_backup_system 2>&1)
    
    # Save to log file
    LOG_FILE="/var/log/company-structure/backup-verification-$(date +%Y%m%d-%H%M%S).log"
    echo "$VERIFICATION_OUTPUT" > "$LOG_FILE"
    
    # Display summary
    echo ""
    print_header "Backup Verification Complete"
    echo "Detailed output saved to: $LOG_FILE"
    echo ""
    echo "To view the full report:"
    echo "  cat $LOG_FILE"
    echo ""
    echo "To run backup scripts:"
    echo "  /root/company-structure/scripts/daily-backup.sh"
    echo "  /root/company-structure/scripts/monthly-backup.sh"
    echo "  /root/company-structure/scripts/comprehensive-backup.sh"
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