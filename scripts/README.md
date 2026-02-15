# Operational Scripts

This directory contains scripts referenced in the company-structure operational documentation.

## Scripts

### `daily-backup.sh`
- **Purpose**: Perform daily incremental backups of Gitea data, configuration files, and SSH keys
- **Location**: `/opt/scripts/daily-backup.sh` (when deployed)
- **Retention**: 7 days
- **Logs**: `/var/log/daily-backup.log`
- **Usage**: Run via cron daily

### `monthly-backup.sh`
- **Purpose**: Perform monthly full system backups including service stop/start
- **Location**: `/opt/scripts/monthly-backup.sh` (when deployed)
- **Retention**: 12 months
- **Logs**: Writes to backup directory log file
- **Usage**: Run via cron monthly (1st day of month)

### `system-health-monitor.sh`
- **Purpose**: Monitor system health and alert on anomalies
- **Location**: `/opt/scripts/system-health-monitor.sh` (when deployed)
- **Checks**: CPU, memory, disk usage, service status, port availability, load average
- **Alerts**: Email and Discord webhook alerts (when configured)
- **Usage**: Run via cron every 15 minutes

## Deployment Instructions

### 1. Create Scripts Directory
```bash
mkdir -p /opt/scripts
cp /root/company-structure/scripts/*.sh /opt/scripts/
chmod +x /opt/scripts/*.sh
```

### 2. Configure Logging
```bash
touch /var/log/daily-backup.log
touch /var/log/system-health.log
chmod 644 /var/log/*.log
```

### 3. Set Up Cron Jobs
```bash
# Edit crontab
crontab -e

# Add these entries:
# Daily backup at 2:00 AM
0 2 * * * /opt/scripts/daily-backup.sh

# Monthly backup on 1st day at 3:00 AM
0 3 1 * * /opt/scripts/monthly-backup.sh

# Health monitor every 15 minutes
*/15 * * * * /opt/scripts/system-health-monitor.sh
```

### 4. Configure Alerts (Optional)
Edit `/opt/scripts/system-health-monitor.sh` and set:
- `EMAIL_ALERT="admin@example.com"` for email alerts
- `DISCORD_WEBHOOK="https://discord.com/api/webhooks/..."` for Discord alerts

## Testing

### Test Backup Script
```bash
sudo -u git /opt/scripts/daily-backup.sh
ls -la /opt/gitea/data.backup/daily/
```

### Test Health Monitor
```bash
/opt/scripts/system-health-monitor.sh
tail -50 /var/log/system-health.log
```

### Verify Cron Jobs
```bash
crontab -l
systemctl status cron
```

## Security Considerations

1. **Permissions**: Scripts should be owned by root with 755 permissions
2. **Logs**: Log files should be readable by admin users only
3. **Backup Storage**: Ensure backup directory has sufficient disk space
4. **Alert Configuration**: Keep alert credentials secure

## Maintenance

1. **Log Rotation**: Script includes basic log rotation; consider logrotate for production
2. **Threshold Tuning**: Adjust thresholds in scripts based on system capacity
3. **Alert Refinement**: Add additional alert channels if needed (Slack, Slack, etc.)
4. **Backup Verification**: Periodically test backup restoration

## Troubleshooting

### Script Not Executing
- Check cron service status: `systemctl status cron`
- Check script permissions: `ls -la /opt/scripts/*.sh`
- Check cron logs: `grep CRON /var/log/syslog`

### Backup Failures
- Verify disk space: `df -h /opt/gitea/data.backup`
- Check Gitea service status before backup
- Verify rsync installation: `which rsync`

### Health Monitor Alerts
- Check log file permissions
- Verify service names match installed services
- Test curl connectivity for Gitea health check

## Integration with Documentation

These scripts implement procedures documented in:
- `OPERATIONS.md` - Daily/weekly/monthly procedures
- `TECHNICAL.md` - Technical infrastructure monitoring
- `INCIDENT_RESPONSE.md` - Early detection of issues

Update scripts when operational procedures change, and update documentation when scripts are modified.