


## Enhanced Daily Operational Checklist

### **Comprehensive Daily Operations Framework**

#### **1. Morning Health Check (08:00 UTC)**

##### **1.1 System Status Assessment**
```bash
# System resources
echo "=== System Resources ==="
uptime
free -h
df -h /
top -bn1 | head -20

# Service status
echo "=== Service Status ==="
systemctl status gitea --no-pager
systemctl status sshd --no-pager
systemctl status fail2ban --no-pager
systemctl status cron --no-pager

# Network status
echo "=== Network Status ==="
ss -tlnp | grep -E ':(22|3000|3001|3002|8880)'
ping -c 3 google.com &>/dev/null && echo "Internet: OK" || echo "Internet: FAILED"

# Backup status
echo "=== Backup Status ==="
ls -lah /opt/gitea/data.backup/ 2>/dev/null || echo "No Gitea backup directory"
ls -lah /var/backups/company-structure/daily/ 2>/dev/null || echo "No daily backup directory"
ls -lah /var/backups/company-structure/monthly/ 2>/dev/null || echo "No monthly backup directory"
```

##### **1.2 Application Health Verification**
```bash
# Gitea accessibility
echo "=== Gitea Health ==="
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/healthz
echo " - Gitea health check"
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/v1/version
echo " - Gitea API version"

# Discovered Python Services (Ports 3002 & 8880)
echo "=== Python Service Status ==="
echo "Port 3002: Security SaaS Service"
ps aux | grep "robust-server.py" | grep -v grep && curl -s -o /dev/null -w "%{http_code}" http://localhost:3002/ && echo " - Running: $(curl -s http://localhost:3002/ | head -c 100)" || echo " - Not responding or authentication required"
echo "Port 8880: DeepInfra Proxy"
ps aux | grep "proxy.py" | grep -v grep && curl -s -o /dev/null -w "%{http_code}" http://localhost:8880/ && echo " - Running: $(curl -s http://localhost:8880/ | head -c 100)" || echo " - Not responding or authentication required"

# Security Warning Check
echo "=== Security Warning ==="
if ss -tlnp | grep -E ':(3002|8880)' | grep -v "127.0.0.1" > /dev/null; then
    echo "⚠️ WARNING: Ports 3002 and/or 8880 publicly accessible without authentication!"
    echo "   Immediate action required: implement firewall or service authentication"
    EXPOSED_COUNT=$(ss -tlnp | grep -E ':(3002|8880)' | grep -v "127.0.0.1" | wc -l)
    echo "   Exposed services count: $EXPOSED_COUNT"
fi

# OpenClaw status
echo "=== OpenClaw Status ==="
systemctl status openclaw-gateway 2>/dev/null || echo "OpenClaw gateway: Not running as service"
pgrep -f openclaw-gateway && echo "OpenClaw gateway: Running" || echo "OpenClaw gateway: Stopped"
```

##### **1.3 Security Posture Check**
```bash
# Firewall status
echo "=== Firewall Status ==="
if command -v ufw &> /dev/null; then
    ufw status verbose
    echo "Firewall: Installed and running"
else
    echo "⚠️ CRITICAL: UFW firewall NOT INSTALLED"
    echo "   Installation command: apt update && apt install ufw -y"
    echo "   Configuration command: ufw default deny incoming; ufw default allow outgoing"
fi

# Fail2Ban status
echo "=== Fail2Ban Status ==="
if systemctl is-active --quiet fail2ban; then
    fail2ban-client status sshd 2>/dev/null || echo "Fail2Ban: Installed but sshd jail not configured"
else
    echo "⚠️ WARNING: Fail2Ban NOT INSTALLED or NOT RUNNING"
    echo "   Installation command: apt install fail2ban -y"
    echo "   Enable command: systemctl enable fail2ban && systemctl start fail2ban"
fi

# Exposed services check
echo "=== Exposed Services Security Assessment ==="
echo "Port 22 (SSH): $(ss -tlnp | grep ':22' | grep -v '127.0.0.1' > /dev/null && echo '⚠️ Publicly exposed' || echo 'OK')"
echo "Port 3000 (Gitea): $(ss -tlnp | grep ':3000' | grep -v '127.0.0.1' > /dev/null && echo '⚠️ Publicly exposed' || echo 'OK')"
echo "Port 3002 (Python Security SaaS): $(ss -tlnp | grep ':3002' | grep -v '127.0.0.1' > /dev/null && echo '❌ CRITICAL - PUBLIC WITHOUT AUTH' || echo 'OK')"
echo "Port 8880 (DeepInfra Proxy): $(ss -tlnp | grep ':8880' | grep -v '127.0.0.1' > /dev/null && echo '❌ CRITICAL - PUBLIC WITHOUT AUTH' || echo 'OK')"

EXPOSED_COUNT=$(ss -tlnp | grep -E ':(22|3000|3001|3002|8880)' | grep -v '127.0.0.1' | wc -l)
echo "Total publicly exposed services (excluding localhost): $EXPOSED_COUNT"
if [ "$EXPOSED_COUNT" -gt 2 ]; then
    echo "⚠️ WARNING: $EXPOSED_COUNT services exposed publicly - reduce attack surface"
fi

# Authentication failures
echo "=== Authentication Failures (Last 24h) ==="
tail -100 /var/log/auth.log | grep -i "fail\|invalid\|refused" | tail -5
```

#### **2. Midday Operations Check (14:00 UTC)**

##### **2.1 Performance Monitoring**
```bash
# Performance metrics
echo "=== Performance Metrics ==="
sar -u 1 3 | tail -3
sar -r 1 3 | tail -3
iostat -x 1 3 | tail -3

# Service responsiveness
echo "=== Service Response Times ==="
TIME=$(time curl -s -o /dev/null http://localhost:3000/ 2>&1 | grep real)
echo "Gitea response: $TIME"
TIME=$(time curl -s -o /dev/null http://localhost:3002/ 2>&1 | grep real)
echo "Nuxt response: $TIME"
```

##### **2.2 Repository & Code Health**
```bash
# Repository status
echo "=== Repository Status ==="
cd /root/company-structure && git fetch origin && git status
cd /root/.openclaw/workspace && git fetch origin && git status

# Backup integrity
echo "=== Backup Integrity ==="
/root/company-structure/scripts/daily-backup.sh --verify 2>/dev/null || echo "Backup verification not implemented"

# CI/CD status
echo "=== CI/CD Status ==="
systemctl status gitea-actions-runner 2>/dev/null || echo "Gitea Actions runner: Not installed"
ps aux | grep ci-runner.sh | grep -v grep && echo "Manual CI runner: Active" || echo "Manual CI runner: Inactive"
```

##### **2.3 Security Log Review**
```bash
# Security log analysis
echo "=== Security Log Analysis ==="
grep -i "attack\|brute\|suspicious\|scan" /var/log/auth.log | tail -10
journalctl -u auditd --since "12 hours ago" 2>/dev/null | tail -20 || echo "Auditd not installed"

# File integrity check
echo "=== File Integrity ==="
/root/company-structure/scripts/file-integrity-check.sh 2>/dev/null || echo "File integrity monitoring not implemented"
```

#### **3. Evening Operations Review (20:00 UTC)**

##### **3.1 Daily Summary**
```bash
# Daily statistics
echo "=== Daily Statistics ==="
echo "CPU peak usage: $(sar -u | tail -1 | awk '{print $3}')%"
echo "Memory peak usage: $(sar -r | tail -1 | awk '{print $4}')%"
echo "Disk usage: $(df -h / | tail -1 | awk '{print $5}')"

# Service uptime
echo "=== Service Uptime ==="
systemctl status gitea --no-pager | grep -E "(Active:|since)"
systemctl status sshd --no-pager | grep -E "(Active:|since)"
```

##### **3.2 Backup Validation**
```bash
# Backup completion
echo "=== Backup Validation ==="
if [ -f /root/company-structure/scripts/daily-backup.sh ]; then
    /root/company-structure/scripts/daily-backup.sh --status
else
    echo "Daily backup script not found"
fi

if [ -f /root/company-structure/scripts/comprehensive-backup.sh ]; then
    echo "Comprehensive backup available"
else
    echo "Comprehensive backup script not found"
fi
```

##### **3.3 Incident Logging**
```bash
# Incident documentation
echo "=== Incident Documentation ==="
DATE=$(date '+%Y-%m-%d')
INCIDENT_FILE="/root/company-structure/incidents/incident-$DATE.md"
mkdir -p "/root/company-structure/incidents"

if [ -f "$INCIDENT_FILE" ]; then
    echo "Incidents logged today: $(grep -c "### Incident" "$INCIDENT_FILE")"
else
    echo "No incidents logged today"
fi
```

#### **4. Automated Monitoring Integration**

##### **4.1 Health Check Script**
Create `/root/company-structure/scripts/daily-health-check.sh`:
```bash
#!/bin/bash
# Daily Health Check Script
HEALTH_LOG="/var/log/company/health-$(date '+%Y-%m-%d').log"

{
    echo "=== Daily Health Check - $(date) ==="
    echo ""
    
    # Run morning checks
    echo "## Morning Checks"
    /root/company-structure/scripts/morning-check.sh 2>/dev/null || echo "Morning check script not found"
    
    # Run midday checks
    echo ""
    echo "## Midday Checks"
    /root/company-structure/scripts/midday-check.sh 2>/dev/null || echo "Midday check script not found"
    
    # Run evening checks
    echo ""
    echo "## Evening Checks"
    /root/company-structure/scripts/evening-check.sh 2>/dev/null || echo "Evening check script not found"
    
    echo ""
    echo "=== Health Check Complete ==="
} > "$HEALTH_LOG"

# Alert on critical issues
if grep -q "CRITICAL\|FAILED\|ERROR" "$HEALTH_LOG"; then
    # Send alert notification
    echo "CRITICAL ISSUES DETECTED - Check $HEALTH_LOG"
fi
```

##### **4.2 Individual Check Scripts**
Create modular check scripts:
```bash
# Morning check script
cat > /root/company-structure/scripts/morning-check.sh << 'EOF'
#!/bin/bash
# Morning health check
echo "=== Morning Health Check ==="
# Add morning-specific checks here
EOF

# Midday check script  
cat > /root/company-structure/scripts/midday-check.sh << 'EOF'
#!/bin/bash
# Midday health check
echo "=== Midday Health Check ==="
# Add midday-specific checks here
EOF

# Evening check script
cat > /root/company-structure/scripts/evening-check.sh << 'EOF'
#!/bin/bash
# Evening health check  
echo "=== Evening Health Check ==="
# Add evening-specific checks here
EOF

chmod +x /root/company-structure/scripts/*.sh
```

##### **4.3 Cron Job Setup**
```bash
# Set up automated health checks
crontab -l > /tmp/cron.temp

# Morning check (08:00 UTC)
echo "0 8 * * * /root/company-structure/scripts/morning-check.sh >> /var/log/company/morning-check.log 2>&1" >> /tmp/cron.temp

# Midday check (14:00 UTC)
echo "0 14 * * * /root/company-structure/scripts/midday-check.sh >> /var/log/company/midday-check.log 2>&1" >> /tmp/cron.temp

# Evening check (20:00 UTC)
echo "0 20 * * * /root/company-structure/scripts/evening-check.sh >> /var/log/company/evening-check.log 2>&1" >> /tmp/cron.temp

# Daily health summary (23:30 UTC)
echo "30 23 * * * /root/company-structure/scripts/daily-health-check.sh >> /var/log/company/daily-health-summary.log 2>&1" >> /tmp/cron.temp

crontab /tmp/cron.temp
rm /tmp/cron.temp
```

#### **5. Operational Reporting**

##### **5.1 Daily Operations Report Template**
```markdown
# Daily Operations Report - $(date '+%Y-%m-%d')

## Executive Summary
- **Overall Status**: [Green/Yellow/Red]
- **Key Issues**: [List any critical issues]
- **Actions Required**: [Immediate actions needed]

## System Health
### Resource Usage
- CPU Utilization: [%] (Threshold: 80%)
- Memory Usage: [%] (Threshold: 90%)
- Disk Usage: [%] (Threshold: 85%)
- Network Connectivity: [Stable/Unstable]

### Service Status
- Gitea: [Operational/Degraded/Down]
- SSH: [Operational/Degraded/Down]
- OpenClaw: [Operational/Degraded/Down]
- Development Services: [Operational/Degraded/Down]

## Security Posture
### Firewall Status
- UFW: [Active/Inactive]
- Rules Applied: [Number]
- Open Ports: [List]

### Intrusion Detection
- Fail2Ban: [Active/Inactive]
- Banned IPs: [Count]
- Authentication Failures: [Count]

### Vulnerability Status
- Critical Vulnerabilities: [Count]
- High Vulnerabilities: [Count]
- Medium Vulnerabilities: [Count]

## Backup Status
### Daily Backups
- Last Backup: [Timestamp]
- Backup Size: [Size]
- Backup Status: [Success/Failed]

### Monthly Backups
- Last Backup: [Timestamp]
- Backup Size: [Size]
- Backup Status: [Success/Failed]

## Incident Log
### Today's Incidents
1. [Incident 1 Description]
   - Time: [Timestamp]
   - Impact: [Low/Medium/High]
   - Status: [Resolved/Investigating]
   - Action Taken: [Description]

2. [Incident 2 Description]
   - Time: [Timestamp]
   - Impact: [Low/Medium/High]
   - Status: [Resolved/Investigating]
   - Action Taken: [Description]

## Performance Metrics
### Response Times
- Gitea API Response: [ms]
- SSH Connection Time: [ms]
- Website Load Time: [ms]

### Throughput
- Git Operations: [Count]
- API Calls: [Count]
- User Sessions: [Count]

## Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]

## Next Steps
1. [Immediate action]
2. [Short-term action]
3. [Long-term action]

---
*Generated by Daily Operations Script v1.0.0*
```

#### **6. Compliance & Audit Trail**

##### **6.1 Daily Audit Log**
```bash
# Create daily audit trail
AUDIT_LOG="/var/log/company/audit-$(date '+%Y-%m-%d').log"

{
    echo "=== Daily Audit Trail - $(date) ==="
    echo ""
    
    # User activities
    echo "## User Activities"
    last -10
    
    # Command history (root)
    echo ""
    echo "## Root Command History"
    history 20
    
    # File modifications
    echo ""
    echo "## Critical File Modifications"
    find /etc /opt /root -type f -mtime -1 -ls | head -20
    
    # Service changes
    echo ""
    echo "## Service Status Changes"
    systemctl list-units --state=failed
    
    echo ""
    echo "=== Audit Complete ==="
} > "$AUDIT_LOG"
```

##### **6.2 Weekly Compliance Report**
Create `/root/company-structure/scripts/weekly-compliance.sh`:
```bash
#!/bin/bash
# Weekly compliance report
REPORT_FILE="/root/company-structure/reports/compliance-week-$(date '+%Y-%W').md"

mkdir -p "/root/company-structure/reports"

{
    echo "# Weekly Compliance Report - Week $(date '+%Y-%W')"
    echo ""
    echo "## Security Compliance"
    echo ""
    echo "### Firewall Rules"
    ufw status verbose 2>/dev/null || echo "UFW not installed"
    echo ""
    echo "### SSH Configuration"
    grep -E "^(PermitRootLogin|PasswordAuthentication|MaxAuthTries)" /etc/ssh/sshd_config
    echo ""
    echo "### Backup Compliance"
    ls -la /var/backups/company-structure/daily/ | tail -7
    echo ""
    echo "### Log Retention"
    find /var/log -name "*.log" -mtime +30 -type f | wc -l
    echo ""
    echo "## Operational Compliance"
    echo ""
    echo "### Service Uptime"
    systemctl status gitea --no-pager | grep -E "(Active:|since)"
    echo ""
    echo "### Repository Updates"
    cd /root/company-structure && git log --oneline -10
    echo ""
    echo "## Recommendations"
    echo ""
    echo "1. [Compliance gap 1]"
    echo "2. [Compliance gap 2]"
    echo "3. [Compliance gap 3]"
    echo ""
    echo "---"
    echo "*Generated by Weekly Compliance Script*"
} > "$REPORT_FILE"
```

### **Implementation Priority**

#### **Phase 1: Foundation (Week 1)**
- [ ] Create basic health check scripts
- [ ] Implement daily operational checklist
- [ ] Set up automated cron jobs
- [ ] Establish monitoring baseline

#### **Phase 2: Enhancement (Week 2)**
- [ ] Develop comprehensive monitoring
- [ ] Implement automated reporting
- [ ] Create compliance tracking
- [ ] Set up alerting system

#### **Phase 3: Optimization (Week 3-4)**
- [ ] Refine check scripts based on feedback
- [ ] Add predictive analytics
- [ ] Implement machine learning anomaly detection
- [ ] Create executive dashboards

### **Verification Commands**
After implementation:
```bash
# Verify scripts are executable
ls -la /root/company-structure/scripts/*.sh

# Verify cron jobs
crontab -l | grep health-check

# Test morning check
/root/company-structure/scripts/morning-check.sh

# Test daily health check
/root/company-structure/scripts/daily-health-check.sh
```

### **Maintenance Schedule**
- **Daily**: Review operational reports, address alerts
- **Weekly**: Update check scripts, review compliance reports
- **Monthly**: Refine monitoring thresholds, update documentation
- **Quarterly**: Comprehensive operational review

---

**Document Version**: 2.0.0  
**Last Updated**: February 15, 2026  
**Next Review**: February 22, 2026  
**Operations Lead**: Rem  
**Approval Required**: Veld (CTO)