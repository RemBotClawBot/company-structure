# Implementation Guide: Security & Operations

*Last Updated: February 15, 2026*
*Version: 2.0.0*

## Overview

This guide provides step-by-step instructions for implementing the security and operational infrastructure documented in the company-structure repository. Each section includes verification commands and troubleshooting steps.

## Table of Contents
1. [Firewall Implementation](#firewall-implementation)
2. [SSH Hardening](#ssh-hardening)
3. [Fail2Ban Installation](#fail2ban-installation)
4. [Service Security](#service-security)
5. [Backup Automation](#backup-automation)
6. [Monitoring Setup](#monitoring-setup)
7. [Financial Tracking](#financial-tracking)
8. [CI/CD Enhancement](#cicd-enhancement)
9. [Troubleshooting](#troubleshooting)
10. [Maintenance Schedule](#maintenance-schedule)

## Firewall Implementation

### UFW Installation and Configuration

#### Step 1: Install UFW
```bash
# Update package list and install UFW
apt update
apt install ufw -y
```

#### Step 2: Configure Default Policies
```bash
# Deny all incoming traffic by default
ufw default deny incoming

# Allow all outgoing traffic by default
ufw default allow outgoing
```

#### Step 3: Allow Required Services
```bash
# Allow SSH on port 22 (critical)
ufw allow 22/tcp comment 'SSH Access'

# Allow Gitea on port 3000
ufw allow 3000/tcp comment 'Gitea Service'

# Optionally allow Forgejo if needed
ufw allow 3001/tcp comment 'Forgejo Staging'

# Block development ports (3002, 8880)
ufw deny 3002/tcp comment 'Development Service - Secure'
ufw deny 8880/tcp comment 'Proxy Service - Secure'

# Allow OpenClaw gateway ports locally only
ufw allow from 127.0.0.1 to any port 18789 comment 'OpenClaw Gateway'
ufw allow from 127.0.0.1 to any port 18792 comment 'OpenClaw Gateway'
```

#### Step 4: Enable the Firewall
```bash
# Enable UFW with force option to avoid prompts
ufw --force enable

# Verify firewall status
ufw status verbose
```

### Verification Commands
```bash
# Check UFW status
ufw status

# Check numbered rules
ufw status numbered

# Validate iptables rules
iptables -L -n -v

# Test blocked ports
sudo netcat -zv 0.0.0.0 3002
sudo netcat -zv 0.0.0.0 8880

# Test allowed ports
sudo netcat -zv 0.0.0.0 22
sudo netcat -zv 0.0.0.0 3000
```

## SSH Hardening

### Step 1: Backup SSH Configuration
```bash
# Create backup of original SSH configuration
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)
```

### Step 2: Update SSH Configuration
Edit `/etc/ssh/sshd_config`:
```bash
# Use nano or your preferred editor
nano /etc/ssh/sshd_config
```

Apply these hardening settings:
```
# Disable root login
PermitRootLogin no

# Disable password authentication (use keys only)
PasswordAuthentication no

# Limit authentication attempts
MaxAuthTries 3

# Limit SSH protocol to version 2
Protocol 2

# Disable empty passwords
PermitEmptyPasswords no

# Use TCP keepalive
TCPKeepAlive yes

# Client alive interval
ClientAliveInterval 300
ClientAliveCountMax 2

# Restart SSH service
```

### Step 3: Apply Changes
```bash
# Test SSH configuration before restarting
sshd -t

# If test passes, restart SSH service
systemctl restart sshd

# Verify SSH service is running
systemctl status sshd
```

### Step 4: Verify SSH Hardening
```bash
# Check configuration
grep -E "^(PermitRootLogin|PasswordAuthentication|MaxAuthTries)" /etc/ssh/sshd_config

# Test SSH connection
ssh -o PasswordAuthentication=no -o PubkeyAuthentication=yes localhost

# Check SSH service logs
journalctl -u sshd --since "today" | tail -20
```

## Fail2Ban Installation

### Step 1: Install Fail2Ban
```bash
# Install Fail2Ban package
apt update
apt install fail2ban -y
```

### Step 2: Configure SSH Protection
Create `/etc/fail2ban/jail.local`:
```bash
# Create custom jail configuration
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 600
findtime = 300
maxretry = 3
banaction = ufw
backend = systemd

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF
```

### Step 3: Enable and Start Fail2Ban
```bash
# Enable Fail2Ban to start on boot
systemctl enable fail2ban

# Start Fail2Ban service
systemctl start fail2ban

# Verify service status
systemctl status fail2ban
```

### Step 4: Test Fail2Ban Configuration
```bash
# Check Fail2Ban status
fail2ban-client status
fail2ban-client status sshd

# Get banned IPs
fail2ban-client banned

# Test with incorrect SSH attempts (in separate terminal)
# ssh user@localhost with wrong password 3 times
# Then check banned IPs:
fail2ban-client status sshd
```

## Service Security

### Step 1: Restrict Development Services
Update service configurations to bind to localhost only:

#### For Nuxt Development Server (port 3002)
Update your Nuxt application configuration:
```bash
# In your Nuxt config, add:
server: {
  host: '127.0.0.1',
  port: 3002
}
```

#### For DeepInfra Proxy (port 8880)
Update the proxy configuration:
```bash
# Bind to localhost only
# Check your DeepInfra proxy configuration file
# Add: bind_address = "127.0.0.1"
```

### Step 2: Verify Service Restrictions
```bash
# Check which services are listening
ss -tlnp

# Should only show public services on ports 22 and 3000
# Services on 3002 and 8880 should only show 127.0.0.1 address
netstat -tlnp | grep -E ':(3002|8880)'
```

## Backup Automation

### Step 1: Setup Backup Scripts
Ensure backup scripts are executable:
```bash
# Make backup scripts executable
chmod +x /root/company-structure/scripts/daily-backup.sh
chmod +x /root/company-structure/scripts/monthly-backup.sh
chmod +x /root/company-structure/scripts/comprehensive-backup.sh
```

### Step 2: Configure Cron Jobs
```bash
# Edit crontab
crontab -e
```

Add these entries:
```
# Daily incremental backup at 2:00 AM UTC
0 2 * * * /root/company-structure/scripts/daily-backup.sh >> /var/log/company-structure/backup-daily.log 2>&1

# Monthly full backup at 3:00 AM UTC on 1st of month
0 3 1 * * /root/company-structure/scripts/monthly-backup.sh >> /var/log/company-structure/backup-monthly.log 2>&1

# Comprehensive backup (manual execution when needed)
# 0 4 * * 0 /root/company-structure/scripts/comprehensive-backup.sh >> /var/log/company-structure/backup-comprehensive.log 2>&1
```

### Step 3: Create Log Directory
```bash
# Create log directory
mkdir -p /var/log/company-structure/

# Set appropriate permissions
chmod 755 /var/log/company-structure/
```

### Step 4: Test Backup Scripts
```bash
# Test with dry-run option
/root/company-structure/scripts/daily-backup.sh --dry-run
/root/company-structure/scripts/monthly-backup.sh --dry-run
/root/company-structure/scripts/comprehensive-backup.sh --dry-run
```

## Monitoring Setup

### Step 1: Enable System Health Monitoring
```bash
# Make monitoring script executable
chmod +x /root/company-structure/scripts/system-health-monitor.sh
```

### Step 2: Configure Monitoring Cron Job
```bash
# Edit crontab
crontab -e
```

Add this entry:
```
# Run system health check every 30 minutes
*/30 * * * * /root/company-structure/scripts/system-health-monitor.sh >> /var/log/company-structure/health-monitor.log 2>&1
```

### Step 3: Enable rsyslog for Enhanced Logging
```bash
# Install rsyslog if not present
apt install rsyslog -y

# Enable and start rsyslog
systemctl enable rsyslog
systemctl start rsyslog

# Verify rsyslog is running
systemctl status rsyslog
```

### Step 4: Configure File Integrity Monitoring (AIDE)
```bash
# Install AIDE
apt install aide -y

# Initialize AIDE database
aideinit

# Copy the new database
cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Test AIDE
aide --check

# Schedule daily AIDE checks
echo "0 4 * * * /usr/bin/aide --check >> /var/log/aide-check.log 2>&1" | crontab -
```

## Financial Tracking

### Step 1: Setup Finance Automation
```bash
# Make finance script executable
chmod +x /root/company-structure/scripts/finance-daily.sh

# Create finance directory if it doesn't exist
mkdir -p /root/company-structure/finance/

# Create backup directory for finance logs
mkdir -p /var/backups/finance/
```

### Step 2: Configure Daily Finance Cron Job
```bash
# Edit crontab
crontab -e
```

Add this entry:
```
# Daily finance tracking at 23:00 UTC
0 23 * * * /root/company-structure/scripts/finance-daily.sh >> /var/log/company-structure/finance-daily.log 2>&1
```

### Step 3: Test Finance Script
```bash
# Run finance script manually
/root/company-structure/scripts/finance-daily.sh

# Verify finance log was created
ls -la /root/company-structure/finance/

# View the finance log
cat /root/company-structure/finance/finance-daily-$(date '+%Y-%m-%d').md | head -30
```

### Step 4: Configure Git Integration
```bash
# Set git identity for automated commits
git config --global user.email "rem@company"
git config --global user.name "Rem Bot"

# Test git integration
cd /root/company-structure
git add finance/finance-daily-$(date '+%Y-%m-%d').md
git commit -m "Test finance commit"
git push origin main
```

## CI/CD Enhancement

### Step 1: Fix Gitea Actions Runner Issue
The current Gitea Actions runner is stuck on "Waiting". Follow these steps:

```bash
# Check current runner status
systemctl status gitea-actions-runner 2>/dev/null || echo "Runner not installed"

# Manual CI runner script execution
/opt/gitea/ci-runner.sh
```

### Step 2: Install Global Dependencies
```bash
# Install Node.js/npm for CI environment
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Install TypeScript and Nuxt dependencies globally
npm install -g typescript
npm install -g nuxt

# Verify installations
node --version
npm --version
tsc --version
```

### Step 3: Configure Manual CI Pipeline
Update `/opt/gitea/ci-runner.sh` to include:
```bash
#!/bin/bash
# CI Runner Script for Gitea Actions

# Set up environment
export NODE_ENV=production
export CI=true

# Navigate to repository
cd /opt/gitea/repositories/{username}/{repo}.git

# Install dependencies
npm install

# Run tests
npm run test

# Build project
npm run build

# Deploy if tests pass
if [ $? -eq 0 ]; then
    echo "Build successful"
    # Add deployment commands here
else
    echo "Build failed"
    exit 1
fi
```

## Troubleshooting

### Common Issues and Solutions

#### Issue: UFW Blocks SSH Access
```bash
# If SSH access is blocked:
ufw --force disable
# Fix SSH rules:
ufw allow 22/tcp
ufw --force enable
```

#### Issue: SSH Key Authentication Fails
```bash
# Check SSH key permissions
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh/

# Verify SSH configuration
grep -E "^(PubkeyAuthentication|AuthorizedKeysFile)" /etc/ssh/sshd_config

# Restart SSH service
systemctl restart sshd
```

#### Issue: Fail2Ban Not Blocking IPs
```bash
# Check Fail2Ban status
fail2ban-client status sshd

# Check logs
tail -50 /var/log/fail2ban.log

# Manually ban an IP for testing
fail2ban-client set sshd banip 192.168.1.100
```

#### Issue: Backup Scripts Fail
```bash
# Check permissions
ls -la /root/company-structure/scripts/*.sh

# Check disk space
df -h

# Test with verbose output
bash -x /root/company-structure/scripts/daily-backup.sh
```

#### Issue: Finance Script Git Commits Fail
```bash
# Check git configuration
git config --list | grep user

# Check repository status
cd /root/company-structure
git status

# Set remote if not configured
git remote add origin https://github.com/RemBotClawBot/company-structure.git
```

#### Issue: Service Ports Still Publicly Accessible
```bash
# Check bound addresses
ss -tlnp | grep -E ':(3002|8880)'

# Stop the services temporarily
# For Nuxt dev server: pkill -f "nuxt"
# For proxy service: pkill -f "proxy"

# Update service configuration to bind to 127.0.0.1
# Restart services
```

## Maintenance Schedule

### Daily Tasks
```bash
# Morning (08:00 UTC)
/root/company-structure/scripts/morning-check.sh

# Midday (14:00 UTC)
/root/company-structure/scripts/midday-check.sh

# Evening (20:00 UTC)
/root/company-structure/scripts/evening-check.sh

# Finance Summary (23:00 UTC)
/root/company-structure/scripts/finance-daily.sh
```

### Weekly Tasks (Sunday 01:00 UTC)
```bash
# Security audit
/root/company-structure/scripts/security-audit.sh

# Log rotation
logrotate /etc/logrotate.d/company-structure

# System updates
apt update && apt upgrade -y
```

### Monthly Tasks (1st of month, 03:00 UTC)
```bash
# Full system backup
/root/company-structure/scripts/monthly-backup.sh

# Security patch update
apt update && apt dist-upgrade -y

# Log analysis
/root/company-structure/scripts/log-analysis.sh
```

### Quarterly Tasks
```bash
# Comprehensive security audit
/root/company-structure/scripts/comprehensive-security-audit.sh

# Infrastructure review
/root/company-structure/scripts/infrastructure-review.sh

# Documentation update
/root/company-structure/scripts/update-documentation.sh
```

## Verification Checklist

After implementation, run this verification script:

```bash
#!/bin/bash
echo "=== Complete Implementation Verification ==="
echo ""

# Check all services are running
echo "1. Service Status:"
systemctl is-active sshd && echo "✅ SSH Active" || echo "❌ SSH Inactive"
systemctl is-active gitea && echo "✅ Gitea Active" || echo "❌ Gitea Inactive"
systemctl is-active fail2ban && echo "✅ Fail2Ban Active" || echo "❌ Fail2Ban Inactive"
systemctl is-active rsyslog && echo "✅ rsyslog Active" || echo "❌ rsyslog Inactive"

echo ""
echo "2. Security Status:"
ufw status | grep -q "Status: active" && echo "✅ UFW Active" || echo "❌ UFW Inactive"
grep "PermitRootLogin no" /etc/ssh/sshd_config && echo "✅ SSH Root Login Disabled" || echo "❌ SSH Root Login Enabled"
grep "PasswordAuthentication no" /etc/ssh/sshd_config && echo "✅ SSH Password Auth Disabled" || echo "❌ SSH Password Auth Enabled"

echo ""
echo "3. Backup Status:"
[ -f /root/company-structure/scripts/daily-backup.sh ] && echo "✅ Daily Backup Script" || echo "❌ Daily Backup Missing"
[ -f /root/company-structure/scripts/monthly-backup.sh ] && echo "✅ Monthly Backup Script" || echo "❌ Monthly Backup Missing"

echo ""
echo "4. Monitoring Status:"
[ -f /root/company-structure/scripts/system-health-monitor.sh ] && echo "✅ Health Monitor Script" || echo "❌ Health Monitor Missing"
crontab -l | grep -q "system-health-monitor" && echo "✅ Health Monitor Cron" || echo "❌ Health Monitor Cron Missing"

echo ""
echo "5. Financial Tracking:"
[ -f /root/company-structure/scripts/finance-daily.sh ] && echo "✅ Finance Script" || echo "❌ Finance Script Missing"
crontab -l | grep -q "finance-daily" && echo "✅ Finance Cron" || echo "❌ Finance Cron Missing"

echo ""
echo "=== Verification Complete ==="
```

Save as `/root/company-structure/scripts/verify-implementation.sh` and run:
```bash
chmod +x /root/company-structure/scripts/verify-implementation.sh
/root/company-structure/scripts/verify-implementation.sh
```

## Emergency Contacts

For issues with implementation:
- **Veld (CTO)**: Primary technical authority
- **Yukine**: Developer for technical assistance
- **Rem**: AI Assistant for automated assistance

---

**Document Version**: 2.0.0  
**Last Updated**: February 15, 2026  
**Next Review**: February 22, 2026  
**Implementation Lead**: Rem  
**Approval Required**: Veld (CTO)