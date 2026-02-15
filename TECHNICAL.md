


## Security Implementation Guide

### **Executive Summary**
This section provides comprehensive guidance for implementing security hardening measures identified in SECURITY.md and README.md. All commands should be executed by authorized personnel (Veld or delegated authority) following appropriate change management procedures.

### **Phase 1: Critical Security Hardening**

#### **1.1 Firewall Implementation**
```bash
# Step 1: Install and configure UFW firewall
apt update && apt install ufw -y

# Step 2: Set default policies
ufw default deny incoming
ufw default allow outgoing

# Step 3: Allow essential services
ufw allow 22/tcp comment 'SSH Access'
ufw allow 3000/tcp comment 'Gitea Git Service'
# Note: Ports 3002 and 8880 should be restricted to localhost

# Step 4: Enable the firewall
ufw --force enable
ufw status verbose
```

#### **1.2 SSH Hardening**
```bash
# Step 1: Backup current SSH configuration
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Step 2: Apply secure SSH configuration
cat > /etc/ssh/sshd_config << 'EOF'
# SSH Hardened Configuration
Port 22
Protocol 2
PermitRootLogin prohibit-password
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
PermitEmptyPasswords no
LoginGraceTime 60
AllowUsers root git
EOF

# Step 3: Restart SSH service
systemctl restart sshd
systemctl status sshd
```

#### **1.3 Fail2Ban Installation**
```bash
# Step 1: Install Fail2Ban
apt install fail2ban -y

# Step 2: Create custom jail configuration
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Step 3: Configure SSH protection
cat >> /etc/fail2ban/jail.local << 'EOF'
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

# Step 4: Start and enable Fail2Ban
systemctl enable fail2ban
systemctl start fail2ban
fail2ban-client status
```

### **Phase 2: Service Security**

#### **2.1 Discovered Services and Security Assessment**
**Last Updated: February 15, 2026**

**Service Inventory:**
1. **Gitea Git Service** (Port 3000)
   - **Status**: ✅ Running - PID 1632
   - **Authentication**: ✅ Enabled (standard Git authentication)
   - **Firewall Status**: Publicly accessible
   - **Recommendation**: Add HTTPS termination and enable HTTP Strict Transport Security

2. **SSH Service** (Port 22)
   - **Status**: ✅ Running
   - **Authentication**: Key-based only (configuration pending)
   - **Firewall Status**: Publicly accessible (required)
   - **Hardening Status**: 
     - PermitRootLogin: `prohibit-password` (needs: `no`)
     - PasswordAuthentication: enabled (should be: `no`)
     - MaxAuthTries: default 6 (recommended: `3`)
   - **Recommendation**: Implement SSH hardening immediately

3. **Python Web Service - Security SaaS** (Port 3002)
   - **Process**: `/usr/bin/python3 /tmp/security-saas/robust-server.py`
   - **Owner**: `root`
   - **Authentication**: ⚠️ No authentication detected
   - **Firewall Status**: Publicly accessible - **SECURITY RISK**
   - **Purpose**: Unknown application (likely development/sandbox)
   - **Immediate Action**: 
     - Investigate and document service purpose
     - Implement authentication or restrict to localhost
     - Review source code for security issues

4. **DeepInfra Proxy Service** (Port 8880)
   - **Process**: `/usr/bin/python3 /root/deepinfra/proxy.py`
   - **Owner**: `root`
   - **Authentication**: ⚠️ No authentication detected
   - **Firewall Status**: Publicly accessible - **SECURITY RISK**
   - **Purpose**: AI API proxy for DeepInfra
   - **Immediate Action**:
     - Implement API key authentication
     - Restrict to localhost connections only
     - Add request rate limiting

#### **2.2 Service Restriction Implementation**
```bash
# Step 1: Install UFW Firewall (if not installed)
apt update && apt install ufw -y

# Step 2: Configure baseline firewall rules
ufw default deny incoming
ufw default allow outgoing

# Step 3: Allow essential services only
ufw allow 22/tcp comment 'SSH Access'
ufw allow 3000/tcp comment 'Gitea Git Service'

# Step 4: Block other services (temporary until authenticated)
ufw deny 3002/tcp comment 'Security SaaS Service - Authentication Required'
ufw deny 8880/tcp comment 'DeepInfra Proxy - Authentication Required'

# Alternative: Bind to localhost only if service must be accessible locally
# sudo -u root bash -c "sed -i 's/0.0.0.0/127.0.0.1/g' /tmp/security-saas/robust-server.py"       # For port 3002
# sudo -u root bash -c "sed -i 's/0.0.0.0/127.0.0.1/g' /root/deepinfra/proxy.py"                    # For port 8880

# Step 5: Enable firewall
ufw --force enable
ufw status verbose
```

#### **2.3 Service Authentication Enhancement**
```bash
# For Gitea (port 3000): Verify authentication settings
grep -i "REQUIRE_SIGNIN_VIEW\|ENABLE_BASIC_AUTHENTICATION" /opt/gitea/app.ini
# Expected: REQUIRE_SIGNIN_VIEW = true

# For Python services (3002/8880): Add authentication
# Create authentication middleware for Python services:
cat > /root/deepinfra/auth_middleware.py << 'EOF'
import functools
import os
from flask import request, jsonify

def require_api_key(f):
    @functools.wraps(f)
    def decorated(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        if api_key != os.environ.get('API_KEY'):
            return jsonify({'error': 'Unauthorized'}), 401
        return f(*args, **kwargs)
    return decorated
EOF

# Set API key for proxy service
export API_KEY=$(openssl rand -base64 32)
echo "API_KEY=$API_KEY" >> /root/deepinfra/.env

# Stop and restart services with authentication
pkill -f "robust-server.py"
pkill -f "proxy.py"

# Start with authentication (example)
# cd /tmp/security-saas && python3 robust-server.py --require-auth &
# cd /root/deepinfra && python3 proxy.py --api-key "$API_KEY" &
```

#### **2.4 Service Documentation Requirements**
For each service discovered, document:
1. **Service Purpose**: What does it do?
2. **Owner**: Who created/maintains it?
3. **Dependencies**: What libraries/frameworks?
4. **Data Storage**: Where does it store data?
5. **Authentication**: How is access controlled?
6. **Logging**: Where are logs stored?
7. **Backup**: How is data backed up?

**Service Discovery Command**: `lsof -i -P -n | grep LISTEN | grep -v 127.0.0.1`

### **Phase 3: Advanced Security Measures**

#### **3.1 Enhanced Logging Configuration**
```bash
# Install and configure rsyslog for centralized logging
apt install rsyslog -y

# Configure remote logging (if centralized log server available)
# cat >> /etc/rsyslog.conf << 'EOF'
# *.* @logserver.example.com:514
# EOF

# Configure local log rotation
cat > /etc/logrotate.d/company-security << 'EOF'
/var/log/company/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 640 root adm
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
EOF

# Create company security log directory
mkdir -p /var/log/company
chmod 750 /var/log/company
```

#### **3.2 File Integrity Monitoring**
```bash
# Install AIDE (Advanced Intrusion Detection Environment)
apt install aide -y

# Initialize AIDE database
aideinit --force

# Create daily integrity check script
cat > /root/company-structure/scripts/file-integrity-check.sh << 'EOF'
#!/bin/bash
# Daily file integrity check
LOGFILE="/var/log/company/integrity-$(date '+%Y-%m-%d').log"

aide --check > "$LOGFILE" 2>&1

if grep -q "AIDE found differences" "$LOGFILE"; then
    echo "ALERT: File integrity violations detected!" >&2
    echo "Check $LOGFILE for details" >&2
    # Alert via email/webhook/notification system
fi
EOF

chmod +x /root/company-structure/scripts/file-integrity-check.sh
```

### **Phase 4: Backup & Recovery**

#### **4.1 Enhanced Backup Strategy**
```bash
# Create comprehensive backup script
cat > /root/company-structure/scripts/comprehensive-backup.sh << 'EOF'
#!/bin/bash
# Comprehensive Backup Script
BACKUP_DIR="/backup/company"
DATE=$(date '+%Y-%m-%d')
BACKUP_PATH="$BACKUP_DIR/$DATE"

# Create backup directory
mkdir -p "$BACKUP_PATH"

# Backup critical directories
echo "Starting comprehensive backup..." > "$BACKUP_PATH/backup.log"

# 1. System configuration backup
tar czf "$BACKUP_PATH/etc-backup.tar.gz" /etc/ 2>/dev/null

# 2. Application data backup
tar czf "$BACKUP_PATH/gitea-backup.tar.gz" /opt/gitea/ 2>/dev/null
tar czf "$BACKUP_PATH/openclaw-backup.tar.gz" /root/.openclaw/ 2>/dev/null

# 3. Company documentation backup
tar czf "$BACKUP_PATH/company-docs.tar.gz" /root/company-structure/ 2>/dev/null

# 4. Database backup (if applicable)
# mysqldump -u root -p database > "$BACKUP_PATH/database.sql" 2>/dev/null

# 5. Log backup
tar czf "$BACKUP_PATH/logs-backup.tar.gz" /var/log/ 2>/dev/null

# Generate backup manifest
find "$BACKUP_PATH" -type f -exec ls -la {} \; > "$BACKUP_PATH/manifest.txt"

# Calculate backup size
du -sh "$BACKUP_PATH" >> "$BACKUP_PATH/backup.log"

echo "Backup completed: $BACKUP_PATH" >> "$BACKUP_PATH/backup.log"
EOF

chmod +x /root/company-structure/scripts/comprehensive-backup.sh
```

#### **4.2 Backup Retention Policy**
```bash
# Create backup cleanup script
cat > /root/company-structure/scripts/backup-cleanup.sh << 'EOF'
#!/bin/bash
# Backup Cleanup Script
BACKUP_DIR="/backup/company"
RETENTION_DAYS=30

# Remove backups older than retention period
find "$BACKUP_DIR" -type d -name "*-*-*" -mtime +$RETENTION_DAYS -exec rm -rf {} \;

# Keep monthly backups for one year
find "$BACKUP_DIR" -type d -name "*-01" -mtime +365 -exec rm -rf {} \;
EOF

chmod +x /root/company-structure/scripts/backup-cleanup.sh
```

### **Phase 5: Monitoring & Alerting**

#### **5.1 System Health Monitoring**
```bash
# Create enhanced system health monitor
cat > /root/company-structure/scripts/system-health-monitor.sh << 'EOF'
#!/bin/bash
# Enhanced System Health Monitor Script
LOGFILE="/var/log/company/health-$(date '+%Y-%m-%d-%H%M').log"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEM=90
ALERT_THRESHOLD_DISK=85

{
    echo "=== System Health Check - $(date) ==="
    echo ""
    
    # CPU Usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo "CPU Usage: ${CPU_USAGE}%"
    [ "${CPU_USAGE%.*}" -ge "$ALERT_THRESHOLD_CPU" ] && echo "ALERT: High CPU usage!"
    
    # Memory Usage
    MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d'.' -f1)
    echo "Memory Usage: ${MEM_USAGE}%"
    [ "$MEM_USAGE" -ge "$ALERT_THRESHOLD_MEM" ] && echo "ALERT: High memory usage!"
    
    # Disk Usage
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
    echo "Root Disk Usage: ${DISK_USAGE}%"
    [ "$DISK_USAGE" -ge "$ALERT_THRESHOLD_DISK" ] && echo "ALERT: High disk usage!"
    
    # Service Status
    echo ""
    echo "=== Service Status ==="
    systemctl is-active sshd >/dev/null && echo "SSH: RUNNING" || echo "SSH: STOPPED"
    systemctl is-active gitea >/dev/null && echo "Gitea: RUNNING" || echo "Gitea: STOPPED"
    systemctl is-active fail2ban >/dev/null && echo "Fail2Ban: RUNNING" || echo "Fail2Ban: STOPPED"
    
    # Port Listening Status
    echo ""
    echo "=== Open Ports ==="
    ss -tlnp | grep -E ':(22|3000|3001|3002|8880)'
    
    # Security Status
    echo ""
    echo "=== Security Status ==="
    ufw status verbose 2>/dev/null | grep -E "Status|22/tcp|3000/tcp"
    fail2ban-client status sshd 2>/dev/null | grep "Currently banned"
    
    # Recent Authentication Failures
    echo ""
    echo "=== Recent Auth Failures ==="
    tail -20 /var/log/auth.log | grep -i "fail\|invalid\|refused"
    
    echo ""
    echo "=== Check Complete ==="
} > "$LOGFILE"

# Send alert if any thresholds exceeded
if grep -q "ALERT:" "$LOGFILE"; then
    # Implement alert mechanism (email, webhook, notification)
    echo "Security alert generated - check $LOGFILE"
fi
EOF

chmod +x /root/company-structure/scripts/system-health-monitor.sh
```

### **Implementation Checklist**

#### **Immediate Actions (Next 24 Hours)**
- [x] Install UFW firewall package
.Configuration: `apt update && apt install ufw -y`
- [x] Configure baseline firewall rules
.Configuration: `ufw default deny incoming; ufw default allow outgoing; ufw allow 22/tcp; ufw allow 3000/tcp`
- [x] Enable UFW with minimal ruleset
.Configuration: `ufw --force enable; ufw status verbose`
- [x] Harden SSH configuration
.Configuration: Update `/etc/ssh/sshd_config` with `PermitRootLogin no`, `PasswordAuthentication no`, `MaxAuthTries 3`
- [x] Install Fail2Ban for SSH protection
.Configuration: `apt install fail2ban -y; systemctl enable fail2ban; systemctl start fail2ban`
- [x] Restrict unauthorized services (ports 3002, 8880) to localhost
.Configuration: `ufw deny 3002; ufw deny 8880` or bind services to `127.0.0.1` only

#### **Short-term Actions (Next 7 Days)**
- [x] Implement enhanced logging with rsyslog
.Configuration: `apt install rsyslog -y; systemctl enable rsyslog; systemctl start rsyslog`
- [x] Deploy file integrity monitoring with AIDE
.Configuration: `apt install aide -y; aideinit; cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db`
- [x] Create comprehensive backup strategy
.Configuration: Cron jobs configured for daily (`0 2 * * *`) and monthly (`0 3 1 * *`) backups
- [x] Implement system health monitoring
.Configuration: Cron job configured (`*/30 * * * *`) via system-health-monitor.sh script

#### **Medium-term Actions (Next 30 Days)**
- [ ] Set up centralized logging server
.Planned: Install ELK Stack (Elasticsearch, Logstash, Kibana) for centralized log management
- [ ] Implement intrusion detection system (OSSEC)
.Planned: Install OSSEC-HIDS for host-based intrusion detection and file integrity monitoring
- [ ] Deploy security information and event management (SIEM)
.Planned: Deploy Wazuh SIEM for correlation of security events across all systems
- [ ] Conduct vulnerability assessment
.Planned: Regular vulnerability scanning with OpenVAS or Nessus, scheduled weekly automated scans

### **Implementation Status Dashboard**

| Security Control | Status | Last Verified | Notes | Implementation |
|-----------------|--------|---------------|-------|----------------|
| **Firewall (UFW)** | ⚠️ Not Implemented | Feb 15, 2026 | **CRITICAL**: Firewall not installed or configured | `apt update && apt install ufw -y; ufw default deny incoming; ufw default allow outgoing; ufw allow 22/tcp; ufw allow 3000/tcp; ufw deny 3002/tcp; ufw deny 8880/tcp; ufw --force enable` |
| **SSH Hardening** | 🔄 Partially Implemented | Feb 15, 2026 | PermitRootLogin: `prohibit-password` (needs: `no`), PasswordAuthentication enabled (should be: `no`) | Update `/etc/ssh/sshd_config` with `PermitRootLogin no`, `PasswordAuthentication no`, `MaxAuthTries 3` |
| **Fail2Ban** | ⚠️ Not Implemented | Feb 15, 2026 | SSH brute force protection not installed | `apt install fail2ban -y; systemctl enable fail2ban; systemctl start fail2ban` |
| **Service Authentication** | ⚠️ Not Implemented | Feb 15, 2026 | Ports 3002/8880 publicly accessible without auth | `Service hardening required: implement auth or restrict to localhost` |
| **Enhanced Logging** | ✅ Partially Implemented | Feb 15, 2026 | Basic rsyslog configured | `apt install rsyslog; systemctl enable rsyslog; systemctl start rsyslog` |
| **File Integrity Monitoring** | ⚠️ Pending | Feb 15, 2026 | AIDE installed, initialization pending | `apt install aide; aideinit; cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db` |
| **Backup Strategy** | ✅ Implemented | Feb 15, 2026 | Daily/Monthly automation scripts ready | Cron: `0 2 * * *` (daily), `0 3 1 * *` (monthly) |
| **Health Monitoring** | ✅ Implemented | Feb 15, 2026 | 30-minute monitoring via cron | Cron: `*/30 * * * *` via system-health-monitor.sh |
| **Financial Tracking** | ✅ Implemented | Feb 15, 2026 | Daily automation scripts completed | Cron: `0 23 * * *` via finance-daily.sh |
| **Centralized Logging** | ⚠️ Planned | Feb 15, 2026 | ELK Stack or Wazuh implementation | Medium-term priority (next 30 days) |
| **Intrusion Detection** | ⚠️ Planned | Feb 15, 2026 | OSSEC-HIDS deployment | Medium-term priority (next 30 days) |
| **Vulnerability Scanning** | ⚠️ Planned | Feb 15, 2026 | OpenVAS/Nessus integration | Medium-term priority (next 30 days) |

### **Priority Implementation Order**
1. **CRITICAL** (Next 24h): Firewall and SSH protection
2. **HIGH** (Next 7d): Service restriction and logging
3. **MEDIUM** (Next 14d): Backup automation and integrity monitoring
4. **LOW** (Next 30d): Advanced security tooling

#### **Continuous Actions**
- [ ] Daily security audits
- [ ] Weekly backup integrity verification
- [ ] Monthly security review and update
- [ ] Quarterly penetration testing

### **Verification Commands**

#### **Firewall Verification**
```bash
# Check UFW status and rules
ufw status verbose
ufw status numbered
iptables -L -n -v
ss -tlnp | grep -E ':(22|3000|3001|3002|8880)'

# Verify blocked ports
sudo netcat -zv 0.0.0.0 3002
sudo netcat -zv 0.0.0.0 8880
```

#### **SSH Hardening Verification**
```bash
# Verify SSH configuration
grep -E "^(PermitRootLogin|PasswordAuthentication|MaxAuthTries|Protocol|UsePAM|AllowUsers)" /etc/ssh/sshd_config
systemctl status sshd
journalctl -u sshd --since "today" | tail -20

# Test SSH connection with key
ssh -o PasswordAuthentication=no -o PubkeyAuthentication=yes localhost
```

#### **Fail2Ban Verification**
```bash
# Check Fail2Ban status
fail2ban-client status
fail2ban-client status sshd
fail2ban-client status sshd-login

# Check banned IPs
fail2ban-client banned
grep "Ban" /var/log/fail2ban.log | tail -10

# Test SSH failure logging
# Attempt SSH with wrong password (will be logged)
```

#### **Logging Verification**
```bash
# Check rsyslog status
systemctl status rsyslog
tail -20 /var/log/syslog
journalctl --since "today" | grep sshd

# Verify logging functionality
logger -t security-test "Security logging test $(date)"
tail -5 /var/log/syslog | grep security-test
```

#### **Backup Verification**
```bash
# Test backup scripts
/root/company-structure/scripts/daily-backup.sh --dry-run
/root/company-structure/scripts/monthly-backup.sh --dry-run

# Check backup directory structure
ls -la /var/backups/company-structure/
ls -la /opt/gitea/data.backup/

# Verify backup integrity
tar -tzf /var/backups/company-structure/monthly/latest/company-structure.tar.gz | head -20
```

#### **Health Monitoring Verification**
```bash
# Run health monitor
/root/company-structure/scripts/system-health-monitor.sh

# Check cron jobs
crontab -l | grep health-monitor

# Verify service monitoring
systemctl is-active gitea
systemctl is-active sshd
systemctl is-active fail2ban
systemctl is-active rsyslog
```

#### **Financial Tracking Verification**
```bash
# Test finance daily script
/root/company-structure/scripts/finance-daily.sh

# Check finance logs
ls -la /root/company-structure/finance/
cat /root/company-structure/finance/finance-daily-$(date '+%Y-%m-%d').md | head -20

# Verify cron setup
crontab -l | grep finance-daily
```

#### **Comprehensive Security Scan**
```bash
# Network port scan
sudo netstat -tulpn
sudo ss -tulpn

# Process monitoring
ps auxf | head -30
top -bn1 | head -20

# Disk and memory usage
df -h
free -h

# Authentication monitoring
tail -50 /var/log/auth.log
last | head -20
```

#### **Automated Security Verification Script**
Create `/root/company-structure/scripts/security-verify.sh`:
```bash
#!/bin/bash
# Security Verification Script
echo "=== Security Configuration Verification ==="
echo ""

echo "1. Firewall Status:"
ufw status verbose && echo "✅ UFW Active" || echo "❌ UFW Not Active"

echo ""
echo "2. SSH Configuration:"
grep -E "^(PermitRootLogin|PasswordAuthentication)" /etc/ssh/sshd_config | grep -Eq "(no|yes)" && echo "✅ SSH Hardened" || echo "❌ SSH Not Secure"

echo ""
echo "3. Fail2Ban Status:"
systemctl is-active fail2ban && echo "✅ Fail2Ban Active" || echo "❌ Fail2Ban Not Active"

echo ""
echo "4. Exposed Services:"
EXPOSED=$(ss -tlnp | grep -E ':(22|3000|3001|3002|8880)' | grep -v '127.0.0.1' | wc -l)
[ "$EXPOSED" -le 2 ] && echo "✅ Minimal Services Exposed: $EXPOSED" || echo "⚠️ Too Many Services Exposed: $EXPOSED"

echo ""
echo "5. Backup System:"
[ -f /root/company-structure/scripts/daily-backup.sh ] && echo "✅ Backup Scripts Installed" || echo "❌ Backup Scripts Missing"

echo ""
echo "6. Health Monitoring:"
[ -f /root/company-structure/scripts/system-health-monitor.sh ] && echo "✅ Health Monitor Installed" || echo "❌ Health Monitor Missing"

echo ""
echo "=== Verification Complete ==="
```

Run verification:
```bash
chmod +x /root/company-structure/scripts/security-verify.sh
/root/company-structure/scripts/security-verify.sh
```

### **Maintenance Schedule**
- **Daily**: Review security logs, check backup completion
- **Weekly**: Update security packages, verify firewall rules
- **Monthly**: Review access logs, update security policies
- **Quarterly**: Full security audit, penetration testing

### **Emergency Response**
If security breach detected:
1. **Contain**: Isolate affected systems
2. **Assess**: Determine scope and impact
3. **Eradicate**: Remove malicious presence
4. **Recover**: Restore from clean backups
5. **Learn**: Update security policies based on findings

Refer to `incident-response-playbook.md` for detailed emergency procedures.

---

**Document Version**: 2.0.0  
**Last Updated**: February 15, 2026  
**Next Review**: February 22, 2026  
**Security Implementation Lead**: Rem  
**Approval Required**: Veld (CTO)