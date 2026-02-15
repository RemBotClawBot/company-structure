


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

#### **2.1 Restricting Unauthorized Services**
```bash
# Restrict Nuxt.js development server (port 3002) to localhost
iptables -A INPUT -p tcp --dport 3002 -s 127.0.0.1 -j ACCEPT
iptables -A INPUT -p tcp --dport 3002 -j DROP

# Restrict DeepInfra proxy (port 8880) to localhost
iptables -A INPUT -p tcp --dport 8880 -s 127.0.0.1 -j ACCEPT
iptables -A INPUT -p tcp --dport 8880 -j DROP

# Save iptables rules
iptables-save > /etc/iptables/rules.v4
apt install iptables-persistent -y
```

#### **2.2 Service Authentication Enhancement**
```bash
# For Gitea (port 3000): Ensure authentication is required
# Check /opt/gitea/app.ini for authentication settings:
grep -i "REQUIRE_SIGNIN_VIEW\|ENABLE_BASIC_AUTHENTICATION" /opt/gitea/app.ini

# For any new services, implement at minimum:
# - Authentication requirement
# - SSL/TLS encryption
# - Rate limiting
# - Access logging
```

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
- [ ] Implement UFW firewall with restrictive rules
- [ ] Install and configure Fail2Ban for SSH protection
- [ ] Harden SSH configuration
- [ ] Restrict unauthorized services (ports 3002, 8880)

#### **Short-term Actions (Next 7 Days)**
- [ ] Implement enhanced logging with rsyslog
- [ ] Deploy file integrity monitoring with AIDE
- [ ] Create comprehensive backup strategy
- [ ] Implement system health monitoring

#### **Medium-term Actions (Next 30 Days)**
- [ ] Set up centralized logging server
- [ ] Implement intrusion detection system (OSSEC)
- [ ] Deploy security information and event management (SIEM)
- [ ] Conduct vulnerability assessment

#### **Continuous Actions**
- [ ] Daily security audits
- [ ] Weekly backup integrity verification
- [ ] Monthly security review and update
- [ ] Quarterly penetration testing

### **Verification Commands**
After implementation, verify security measures:
```bash
# Firewall status
ufw status verbose

# SSH configuration
grep -E "^(PermitRootLogin|PasswordAuthentication|MaxAuthTries)" /etc/ssh/sshd_config

# Fail2Ban status
fail2ban-client status sshd

# Service restrictions
iptables -L -n | grep -E "3002|8880"

# Backup test
/root/company-structure/scripts/comprehensive-backup.sh

# Health check
/root/company-structure/scripts/system-health-monitor.sh
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