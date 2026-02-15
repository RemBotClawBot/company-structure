# Operational Procedures & Playbooks

## Table of Contents
1. [Daily Operations](#daily-operations)
2. [System Administration](#system-administration)
3. [Change Management](#change-management)
4. [Incident Response](#incident-response)
5. [Onboarding Procedures](#onboarding-procedures)
6. [Communication Protocols](#communication-protocols)

## Daily Operations

### Morning Health Check (08:00 UTC)
```bash
# 1. System Status
systemctl status gitea
ss -tlnp | grep -E "(22|3000)"
df -h /

# 2. Service Accessibility
curl -s http://localhost:3000/healthz
curl -s http://46.224.129.229:3000/

# 3. Backup Verification
ls -lah /opt/gitea/data.backup/
du -sh /opt/gitea/data/

# 4. Log Review
tail -100 /var/log/syslog | grep -i "(error|fail|warn)"
journalctl -u gitea --since "24 hours ago" | tail -50

# 5. Repository Status
cd /root/company-structure && git status
cd /root/.openclaw/workspace && git status
```

### Midday Maintenance (12:00 UTC)
```bash
# 1. Security Updates
apt update && apt list --upgradable

# 2. Memory Maintenance
# Review MEMORY.md for significant events
# Update from memory/YYYY-MM-DD.md files

# 3. Documentation Review
# Check company-structure repository for updates needed
# Verify all operational docs are current

# 4. Competitive Monitoring
# Check for any unusual activity
# Review security logs for suspicious patterns
```

### Evening Review (20:00 UTC)
```bash
# 1. Performance Metrics
top -b -n 1 | head -20
free -h

# 2. Backup Creation (if significant changes)
cp -r /opt/gitea/data /opt/gitea/data.backup/daily.$(date +%Y%m%d)

# 3. Access Log Review
journalctl _SYSTEMD_UNIT=sshd.service --since "24 hours ago"

# 4. Automated Task Verification
# Check cron job executions
# Verify heartbeat tasks completed
```

## System Administration

### User Management Procedures

#### Adding New Developer
```bash
# 1. Identity Verification
# Confirm with CEO Gerard and CTO Veld
# Verify GitHub/LinkedIn profiles

# 2. Gitea Account Creation
# Login as admin to http://46.224.129.229:3000/
# Create user account with strong temporary password
# Assign appropriate repository permissions

# 3. SSH Access Provisioning
# Generate ED25519 SSH key pair for user
# Add public key to ~/.ssh/authorized_keys
# Provide private key securely to developer

# 4. Onboarding Documentation
# Provide access to company-structure repository
# Schedule initial security briefing
# Assign mentor (Gerard or Yukine)
```

#### Removing Access
```bash
# 1. Repository Transfer
# Transfer all repositories to another account
# Verify transfer completion

# 2. Account Disablement
# Disable Gitea account
# Remove from admin groups

# 3. SSH Key Removal
# Remove public key from authorized_keys
# Notify user of access revocation

# 4. Security Audit
# Review logs for any suspicious activity
# Verify no residual access remains
```

### Backup Procedures

#### Script Inventory
| Script | Location | Purpose | Log File | Retention |
|--------|----------|---------|----------|-----------|
| Daily Incremental Backup | `scripts/daily-backup.sh` | Captures working Gitea data + configs every night | `/var/log/daily-backup.log` | 7 days of daily snapshots |
| Monthly Full Backup | `scripts/monthly-backup.sh` | Creates service-stopped tarball of Gitea, OpenClaw config, SSH keys | `/var/log/monthly-backup.log` | 12 monthly archives |
| System Health Monitor | `scripts/system-health-monitor.sh` | 30-min sweeps of CPU/RAM/disk/services/ports | `/var/log/system-health.log` (+ `/var/log/system-alerts.log`) | N/A |

All scripts live in this repository under `scripts/` (tracked in git) and should be copied to `/root/company-structure/scripts/` on the host with executable permissions. After every edit, re-run `chmod +x` to keep them executable.

#### Daily Incremental Backup
- **Command**: `sudo /root/company-structure/scripts/daily-backup.sh`
- **What it does**: rsyncs `/opt/gitea/data`, captures `/opt/gitea/app.ini`, `/root/.openclaw/config.yaml`, and SSH keys into `/opt/gitea/data.backup/daily/<YYYYMMDD>/` with a JSON manifest and retention pruning.
- **Cron**: `0 2 * * * root /root/company-structure/scripts/daily-backup.sh` (edit `/etc/crontab`).
- **Verification**: inspect `/var/log/daily-backup.log` and `manifest.json` in the latest backup folder; log results in MEMORY.md if anomalies appear.

#### Monthly Full Backup
- **Command**: `sudo /root/company-structure/scripts/monthly-backup.sh`
- **What it does**: stops Gitea, archives `/opt/gitea`, the OpenClaw runtime, and SSH config into `/opt/gitea/data.backup/monthly/full-backup-<YYYYMM>.tar.gz`, restarts services, verifies archive integrity, and enforces a 12-month retention policy.
- **Cron**: `0 3 1 * * root /root/company-structure/scripts/monthly-backup.sh`.
- **Recovery test**: run `tar -tzf /opt/gitea/data.backup/monthly/<YYYYMM>/full-backup.tar.gz | head` after each backup and perform a full restore rehearsal quarterly.

#### Automated Monitoring Script
- **Command**: `sudo /root/company-structure/scripts/system-health-monitor.sh`
- **Signals**: writes OK/Warning/Critical summaries, tracks CPU, memory, disk, swap, key services (gitea/ssh/openclaw/fail2ban/ufw), listening ports (22/3000/3002/8880/18789), connectivity checks, and recent SSH failures.
- **Alerts**: critical findings append to `/var/log/system-alerts.log`. Integrate the placeholder webhook in the script once a Discord/Slack endpoint is provisioned.
- **Cron**: `*/30 * * * * root /root/company-structure/scripts/system-health-monitor.sh`.
- **Follow-up**: non-zero exit status or new entries in `/var/log/system-alerts.log` should trigger an incident review; summarize the outcome in MEMORY.md + INCIDENT_RESPONSE.md when applicable.

### Service Management

#### Starting Gitea Service
```bash
systemctl start gitea
systemctl status gitea
curl http://localhost:3000/healthz
```

#### Restarting Services
```bash
# Graceful restart
systemctl restart gitea

# Verify service health
sleep 5
systemctl status gitea
curl -s http://localhost:3000/ | grep -q "Gitea"
```

#### Checking Service Health
```bash
# Service status
systemctl is-active gitea
systemctl is-enabled gitea

# Port listening check
ss -tlnp | grep 3000

# Process check
ps aux | grep gitea | grep -v grep

# Log tail
journalctl -u gitea -n 20 --no-pager
```

## Change Management

### Standard Change Procedure
1. **Request Submission**
   - Document change in MEMORY.md
   - Specify reason, scope, and risk assessment
   - Obtain approval from CTO Veld

2. **Pre-Implementation**
   - Create backup: `/opt/gitea/data.backup/change-$(date +%Y%m%d)`
   - Document current state
   - Schedule implementation window

3. **Implementation**
   - Execute changes
   - Monitor for issues
   - Document each step

4. **Verification**
   - Test functionality
   - Verify no regression
   - Update documentation

5. **Post-Implementation**
   - Update MEMORY.md with results
   - Notify relevant parties
   - Schedule follow-up review

### Emergency Change Procedure
1. **Immediate Action**
   - Take if absolutely necessary
   - Document rationale in MEMORY.md ASAP
   - Notify CTO Veld immediately

2. **Mitigation**
   - Create emergency backup
   - Implement minimal viable change
   - Monitor closely

3. **Follow-up**
   - Full documentation within 24 hours
   - Post-mortem analysis
   - Procedure update if needed

## Incident Response

### Security Incident Classification

#### Level 1: Critical
- Unauthorized root access
- Data breach confirmed
- Service compromise
- Ransomware detection

**Response Time**: Immediate
**Escalation**: CEO Gerard + CTO Veld

#### Level 2: High
- Suspicious login attempts
- Potential data exposure
- Service disruption
- Configuration breach

**Response Time**: 1 hour
**Escalation**: CTO Veld

#### Level 3: Medium
- Unusual but non-critical activity
- Minor configuration issues
- Performance degradation
- Backup failures

**Response Time**: 4 hours
**Escalation**: Senior developer (Yukine)

#### Level 4: Low
- Informational security events
- Routine maintenance issues
- Documentation updates
- Performance monitoring alerts

**Response Time**: 24 hours
**Escalation**: AI Assistant (Rem)

### Incident Response Steps

#### Step 1: Identification
```bash
# Log review
journalctl --since "1 hour ago" | grep -i "fail\|error\|warn\|auth"
tail -100 /var/log/auth.log
ss -tlnp | grep -v ":22\|:3000"

# Process examination
ps aux | grep -v "\["
lsof -i -n -P

# File integrity
find /opt/gitea/data/ -type f -newermt "1 hour ago"
```

#### Step 2: Containment
```bash
# Isolate affected systems
systemctl stop gitea  # If compromised
iptables -A INPUT -s <attacker_ip> -j DROP

# Preserve evidence
cp -r /opt/gitea/data /tmp/evidence/
cp /var/log/syslog /tmp/evidence/

# Change credentials
passwd git
```

#### Step 3: Eradication
```bash
# Remove malicious components
find / -type f -name "*.sh" -exec grep -l "malicious" {} \;
rm -f /tmp/suspicious_file

# Patch vulnerabilities
apt update && apt upgrade

# Update firewall rules
ufw deny from <malicious_network>
```

#### Step 4: Recovery
```bash
# Restore from backup
systemctl stop gitea
rm -rf /opt/gitea/data
cp -r /opt/gitea/data.backup/latest/ /opt/gitea/data/
systemctl start gitea

# Verify restoration
curl http://localhost:3000/
```

#### Step 5: Post-Incident
1. **Documentation**
   - Update MEMORY.md with incident details
   - Create incident report in company-structure
   - Update security procedures if needed

2. **Review**
   - Conduct post-mortem meeting
   - Identify root cause
   - Implement preventative measures

3. **Communication**
   - Notify stakeholders
   - Update status pages if public
   - Legal/compliance reporting if required

## Onboarding Procedures

### New Developer Checklist

#### Pre-arrival (Day -7)
- [ ] Identity verification completed
- [ ] Equipment procurement ordered
- [ ] Account credentials generated
- [ ] Security briefing scheduled

#### Day 1: Welcome & Setup
- [ ] Welcome meeting with CEO Gerard
- [ ] Security briefing with CTO Veld
- [ ] Account provisioning completed
- [ ] Development environment setup

#### Week 1: Integration
- [ ] Repository access granted
- [ ] Codebase overview completed
- [ ] First task assigned
- [ ] Mentor pairing established

#### Month 1: Ramp-up
- [ ] Project contribution made
- [ ] Security protocols tested
- [ ] Performance review scheduled
- [ ] Documentation contributions

### AI Assistant Onboarding
- [ ] MEMORY.md review completed
- [ ] Access to company-structure repository
- [ ] Security clearance verified
- [ ] Operational procedures training
- [ ] First heartbeat check successful

## Communication Protocols

### Emergency Communication
```
Primary: Discord DMs
Secondary: Email
Backup: Signal/Telegram
```

### Status Reporting
- **Daily**: Heartbeat summary to CEO Gerard
- **Weekly**: Progress report to CTO Veld
- **Monthly**: Comprehensive review with all stakeholders

### Meeting Schedule
- **Daily Standup**: 09:00 UTC (AI Assistant status)
- **Weekly Sync**: Monday 14:00 UTC (Technical team)
- **Monthly Review**: First Monday 16:00 UTC (All-hands)

### Documentation Updates
- **Immediate**: Security incidents, critical changes
- **Daily**: Operational logs, system status
- **Weekly**: Progress reports, meeting notes
- **Monthly**: Comprehensive reviews, procedure updates

## Performance Metrics

### System Metrics to Monitor
```bash
# CPU Usage
top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}'

# Memory Usage
free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}'

# Disk Usage
df -h / | awk 'NR==2{print $5}'

# Service Uptime
systemctl is-active gitea && echo "Gitea: Active" || echo "Gitea: Inactive"

# Response Time
time curl -s -o /dev/null -w "%{time_total}" http://localhost:3000/
```

### Quality Metrics
- **Code Coverage**: TBD (when CI implemented)
- **Deployment Frequency**: Manual currently
- **Lead Time for Changes**: TBD
- **Mean Time to Recovery**: TBD
- **Change Failure Rate**: TBD

---

*These operational procedures should be reviewed quarterly and updated as needed. All team members must be familiar with their responsibilities.*