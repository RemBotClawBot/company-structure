# Scripts Directory

This directory contains automation scripts for company operations, security, backup, and monitoring.

## Script Inventory

### Security Hardening (`security-hardening.sh`)
Comprehensive security hardening automation for Ubuntu 24.04 LTS.

**Features**:
- UFW firewall installation and configuration
- Fail2Ban installation and SSH brute force protection
- SSH hardening with modern cryptography
- Enhanced system logging with auditd
- Security monitoring with logwatch
- System-wide hardening via sysctl
- Comprehensive backup plan creation

**Usage**:
```bash
# Run all hardening steps (requires root)
sudo bash security-hardening.sh --all

# Run individual components
sudo bash security-hardening.sh --install-firewall
sudo bash security-hardening.sh --harden-ssh
sudo bash security-hardening.sh --setup-logging
sudo bash security-hardening.sh --harden-system
```

**Warning**: This script makes significant changes to system configuration. Review thoroughly before execution.

### Comprehensive Backup (`comprehensive-backup.sh`)
Creates comprehensive system backups including company-structure repository, Gitea data, OpenClaw workspace, system configurations, and logs.

**Backup Contents**:
- Company-structure repository
- Gitea data and configuration
- OpenClaw workspace
- System configurations (SSH, UFW, Fail2Ban)
- Recent system logs

**Retention Policy**:
- Daily backups: Keep 7 days
- Weekly backups: Keep 30 days
- Monthly backups: Keep 365 days

**Usage**:
```bash
# Run comprehensive backup
sudo bash comprehensive-backup.sh
```

### Daily Backup (`daily-backup.sh`)
Incremental daily backups with rsync and 7-day retention.

**Features**:
- Incremental rsync backups
- Backup manifest generation
- 7-day retention policy
- Log rotation and cleanup

**Cron Schedule**: `0 2 * * *` (2:00 AM daily)

### Monthly Backup (`monthly-backup.sh`)
Full monthly backup with service stop/start and integrity verification.

**Features**:
- Stops Gitea service during backup
- Creates full tarball backup
- Validates backup integrity
- 12-month retention policy
- Service restart verification

**Cron Schedule**: `0 3 1 * *` (3:00 AM on 1st of month)

### System Health Monitor (`system-health-monitor.sh`)
30-minute health checks monitoring CPU, RAM, disk, services, ports, and SSH logs.

**Monitoring Includes**:
- CPU/RAM/Disk usage
- Service status (Gitea, OpenClaw)
- Port accessibility (22, 3000, 3002, 8880)
- SSH authentication failures
- Log file growth

**Alerting**: Critical issues logged to `/var/log/system-alerts.log`

**Cron Schedule**: `*/30 * * * *` (Every 30 minutes)

## Deployment

### Script Setup
```bash
# Make all scripts executable
chmod +x /root/company-structure/scripts/*.sh

# Create symlinks for easy access
ln -sf /root/company-structure/scripts/*.sh /usr/local/bin/
```

### Cron Configuration
```bash
# Add to /etc/crontab
0 2 * * * root /root/company-structure/scripts/daily-backup.sh
0 3 1 * * root /root/company-structure/scripts/monthly-backup.sh
*/30 * * * * root /root/company-structure/scripts/system-health-monitor.sh
```

### Log Configuration
```bash
# Create log directory
mkdir -p /var/log/company-structure/

# Set permissions
chmod 755 /var/log/company-structure/
```

## Testing

### Dry Run Tests
```bash
# Test backup scripts (without actual service interruption)
bash daily-backup.sh --dry-run
bash monthly-backup.sh --dry-run

# Test security hardening (review changes only)
bash security-hardening.sh --help
bash security-hardening.sh --install-firewall --dry-run
```

### Integration Tests
```bash
# Run health monitor test
bash system-health-monitor.sh

# Verify backup integrity
tar -tzf /var/backups/company-structure/daily/YYYYMMDD_HHMMSS/company-structure.tar.gz

# Check firewall status
ufw status verbose
```

## Security Considerations

### Permissions
- All scripts require root privileges
- Backup files stored with restrictive permissions (600)
- Log files readable by root only

### Safe Execution
1. **Backup First**: Always create system backup before running security hardening
2. **Review Changes**: Examine script diff before applying
3. **Staged Rollout**: Test in non-production environment first
4. **Monitoring**: Enable additional monitoring after changes

### Recovery Procedures
If security hardening causes issues:
1. Restore from backup (`comprehensive-backup.sh` creation)
2. Review SSH configuration backup (`/etc/ssh/sshd_config.backup.YYYYMMDD`)
3. Check firewall rules (`ufw disable` temporarily)
4. Review audit logs (`journalctl -u auditd`)

## Maintenance

### Regular Updates
- Review scripts quarterly for security updates
- Test after Ubuntu package updates
- Update documentation with any changes

### Monitoring
- Check `/var/log/company-structure/` for script errors
- Monitor `/var/log/system-alerts.log` for critical alerts
- Review backup success via log files

### Contribution Guidelines
1. Document all changes in script headers
2. Include usage examples
3. Add dry-run options for destructive operations
4. Maintain backward compatibility when possible
5. Update this README with new script information

---

*Last Updated: February 15, 2026*