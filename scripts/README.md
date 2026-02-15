# Scripts Directory - Automation & Security

This directory contains automation scripts for security hardening, backup operations, financial tracking, and system monitoring.

## Available Scripts

### Security Automation
1. **security-hardening.sh** - Complete Ubuntu 24.04 LTS security hardening script
   - Implements firewall, SSH hardening, Fail2Ban
   - Configures logging and monitoring
   - Sets up security baseline

2. **security-verify.sh** - Security compliance verification script
   - Checks implemented security controls
   - Validates firewall rules and SSH configuration
   - Verifies intrusion detection systems
   - Reports on security posture

3. **backup-verify.sh** - Backup integrity verification script
   - Validates backup file integrity
   - Checks backup retention policies
   - Verifies restore procedures
   - Reports backup compliance

### Backup Operations
1. **daily-backup.sh** - Incremental daily backup automation
   - Creates timestamped backups
   - Maintains retention policies
   - Logs backup operations
   - Verifies backup integrity

2. **monthly-backup.sh** - Full monthly backup automation
   - Comprehensive system backup
   - Long-term retention management
   - Archive integrity checks
   - Compression optimization

### System Monitoring
1. **system-health-monitor.sh** - 30-minute system health monitoring
   - CPU, memory, disk usage monitoring
   - Service status checks
   - Security posture assessment
   - Alert threshold detection
   - Report generation

### Financial Tracking
1. **finance-daily.sh** - Daily financial tracking automation
   - Expenditure logging
   - Revenue tracking
   - Financial report generation
   - Alert generation for anomalies

## Cron Job Recommendations

### Security Monitoring (Every 30 minutes)
```bash
*/30 * * * * /root/company-structure/scripts/system-health-monitor.sh
```

### Daily Financial Tracking (11 PM UTC)
```bash
0 23 * * * /root/company-structure/scripts/finance-daily.sh
```

### Daily Backups (2 AM UTC)
```bash
0 2 * * * /root/company-structure/scripts/daily-backup.sh
```

### Monthly Backups (3 AM on 1st of month)
```bash
0 3 1 * * /root/company-structure/scripts/monthly-backup.sh
```

### Security Verification (Daily at 9 AM)
```bash
0 9 * * * /root/company-structure/scripts/security-verify.sh >> /var/log/company-structure/security-verify.log 2>&1
```

### Backup Verification (Weekly, Sunday at 4 AM)
```bash
0 4 * * 0 /root/company-structure/scripts/backup-verify.sh >> /var/log/company-structure/backup-verify.log 2>&1
```

## Implementation Status

| Script | Cron Job Set | Last Execution | Status |
|--------|--------------|----------------|--------|
| system-health-monitor.sh | ✅ Yes (every 30 min) | Feb 15, 2026 | Operational |
| finance-daily.sh | ⚠️ Pending cron (`0 23 * * *`) | Manual runs only | Ready for deployment |
| daily-backup.sh | ⚠️ Pending cron (`0 2 * * *`) | Manual runs only | Ready for deployment |
| monthly-backup.sh | ⚠️ Pending cron (`0 3 1 * *`) | Manual runs only | Ready for deployment |
| security-verify.sh | ⚠️ Pending cron (`0 9 * * *`) | Not yet run | Ready for deployment |
| backup-verify.sh | ⚠️ Pending cron (`0 4 * * 0`) | Not yet run | Ready for deployment |

## Security Compliance

All scripts should be:
1. **Executable**: `chmod +x scriptname.sh`
2. **Secure**: No hardcoded credentials
3. **Logged**: All operations logged for audit
4. **Tested**: Validated in controlled environment
5. **Documented**: Purposes and risks documented

## Usage Examples

### Run Security Hardening
```bash
sudo /root/company-structure/scripts/security-hardening.sh
```

### Manual Health Check
```bash
sudo /root/company-structure/scripts/system-health-monitor.sh
```

### Manual Backup Verification
```bash
sudo /root/company-structure/scripts/backup-verify.sh
```

### Generate Financial Report
```bash
sudo /root/company-structure/scripts/finance-daily.sh
```

## Maintenance Schedule

- **Weekly**: Review script logs and update as needed
- **Monthly**: Verify all cron jobs are running correctly
- **Quarterly**: Review and update scripts for security compliance
- **Annually**: Complete script audit and documentation review

---

**Last Updated**: February 15, 2026  
**Security Verification**: Rem ⚡