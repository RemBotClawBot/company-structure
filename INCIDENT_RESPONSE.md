# Incident Response Playbook

## Quick Reference

### Emergency Contacts
- **CEO Gerard**: Highest authority, final decision maker
- **CTO Veld**: Technical authority, escalation point
- **Developer Yukine**: Technical operations support
- **AI Assistant Rem**: Automated monitoring and documentation

### Immediate Actions Matrix
| Incident Type | First Action | Escalate To | Timeframe |
|--------------|--------------|-------------|-----------|
| **Unauthorized Access** | Isolate system, preserve logs | CTO Veld | IMMEDIATE |
| **Data Breach** | Secure evidence, contain spread | CEO Gerard | IMMEDIATE |
| **Service Outage** | Failover/restart, assess impact | CTO Veld | 15 MINUTES |
| **Competitor Interference** | Document activity, secure assets | CEO Gerard | 1 HOUR |
| **Identity Conflict** | Freeze accounts, verify authority | CTO Veld | IMMEDIATE |

## Incident Classification

### Severity Levels

#### SEVERITY 1: CRITICAL
**Definition**: Complete service disruption, confirmed data breach, unauthorized root access
**Examples**:
- Gitea completely inaccessible
- Root compromise confirmed
- Sensitive data exfiltrated
- Ransomware infection

**Response Time**: IMMEDIATE (within 15 minutes)
**Notification Chain**: AI Assistant → Developer Yukine → CTO Veld → CEO Gerard
**Target Resolution**: 4 hours

#### SEVERITY 2: HIGH
**Definition**: Partial service disruption, potential data exposure, suspicious activity
**Examples**:
- Gitea performance degradation
- Unauthorized login attempts
- Configuration file tampering
- Competitor interference detected

**Response Time**: 1 HOUR
**Notification Chain**: AI Assistant → Developer Yukine → CTO Veld
**Target Resolution**: 24 hours

#### SEVERITY 3: MEDIUM
**Definition**: Non-critical issues affecting operations, security concerns
**Examples**:
- Backup failures
- Documentation inconsistencies
- Minor configuration errors
- Performance monitoring alerts

**Response Time**: 4 HOURS
**Notification Chain**: AI Assistant → Developer Yukine
**Target Resolution**: 3 days

#### SEVERITY 4: LOW
**Definition**: Informational, routine maintenance, documentation updates
**Examples**:
- Routine security scan findings
- Documentation improvements needed
- Performance optimization opportunities
- Feature requests

**Response Time**: NEXT BUSINESS DAY
**Notification Chain**: AI Assistant
**Target Resolution**: 1 week

## Incident Response Procedures

### Phase 1: Identification & Triage

#### Step 1: Initial Detection
```bash
# Automated Monitoring Alerts
# Check heartbeat monitoring
# Review security logs
# Verify service status

# Manual Detection
# User reports
# System anomalies
# External notifications
```

#### Step 2: Initial Assessment
```bash
# Quick System Check
systemctl status gitea
ss -tlnp | grep 3000
ps aux | grep gitea

# Log Review
tail -100 /var/log/syslog | grep -i "error\|fail\|auth"
journalctl -u gitea --since "5 minutes ago"

# Network Check
netstat -an | grep ESTABLISHED
iptables -L -n -v
```

#### Step 3: Severity Classification
```bash
# Use classification matrix above
# Document in MEMORY.md immediately
# Example entry format:
# [INCIDENT] SEVERITY 2: Multiple failed SSH attempts from unknown IP
# Time: $(date)
# Actions: Initial investigation, logs preserved
```

### Phase 2: Containment

#### For SEVERITY 1-2 Incidents
```bash
# Immediate Isolation
systemctl stop gitea  # If service compromised
iptables -A INPUT -s <malicious_ip> -j DROP

# Evidence Preservation
mkdir -p /tmp/incident_$(date +%Y%m%d_%H%M%S)
cp -r /opt/gitea/data /tmp/incident_*/data_backup/
cp /var/log/* /tmp/incident_*/logs/
lsof -i -n -P > /tmp/incident_*/network_connections.txt

# Secure Communication
# Use Discord DMs for sensitive discussions
# Document all actions in MEMORY.md
```

#### For SEVERITY 3-4 Incidents
```bash
# Limited Containment
# Monitor closely
# Increase logging
# Prepare backup
```

### Phase 3: Investigation

#### Evidence Collection Checklist
```bash
# System Information
uname -a > /tmp/incident_*/system_info.txt
hostname >> /tmp/incident_*/system_info.txt

# User Sessions
who > /tmp/incident_*/user_sessions.txt
last >> /tmp/incident_*/user_sessions.txt

# Process Analysis
ps aux --sort=-%cpu > /tmp/incident_*/processes.txt
lsof -i -n -P >> /tmp/incident_*/processes.txt

# File System Analysis
find /opt/gitea -type f -newermt "24 hours ago" -ls
find /root/.openclaw -type f -newermt "24 hours ago" -ls

# Network Analysis
netstat -tulpn > /tmp/incident_*/network.txt
ss -tulpn >> /tmp/incident_*/network.txt

# Log Collection
journalctl --since "24 hours ago" > /tmp/incident_*/journal.txt
tail -1000 /var/log/syslog > /tmp/incident_*/syslog.txt
```

#### Root Cause Analysis Steps
1. **Timeline Reconstruction**
   - Document first detection time
   - Note all subsequent events
   - Identify potential entry points

2. **Impact Assessment**
   - Data affected
   - Systems compromised
   - Services disrupted
   - Reputation damage

3. **Vulnerability Identification**
   - Configuration weaknesses
   - Software vulnerabilities
   - Human factors
   - Process failures

### Phase 4: Eradication

#### Removal Procedures
```bash
# Malicious Process Termination
kill -9 $(pidof malicious_process)

# File Removal
find / -type f -name "*.sh" -exec grep -l "suspicious_pattern" {} \;
rm -f /tmp/malicious_file

# Account Cleanup
# Review /etc/passwd for suspicious accounts
# Check authorized_keys for unauthorized entries
# Review sudoers file for privilege escalation

# Configuration Reset
cp /opt/gitea/app.ini.backup /opt/gitea/app.ini
cp /root/.openclaw/config.yaml.backup /root/.openclaw/config.yaml
```

#### Patch Application
```bash
# Security Updates
apt update
apt upgrade --security-only

# Configuration Hardening
# Implement lessons learned
# Update firewall rules
# Strengthen authentication
```

### Phase 5: Recovery

#### Service Restoration
```bash
# Stop Service
systemctl stop gitea

# Restore from Clean Backup
rm -rf /opt/gitea/data
cp -r /opt/gitea/data.backup/clean_backup/ /opt/gitea/data/

# Apply Security Patches
apt update && apt upgrade

# Restart Service
systemctl start gitea

# Verification
sleep 10
systemctl status gitea
curl http://localhost:3000/healthz
```

#### Data Validation
```bash
# Integrity Check
find /opt/gitea/data -type f -exec md5sum {} \; > /tmp/data_validation.md5
diff /tmp/backup_validation.md5 /tmp/data_validation.md5

# Functional Testing
# Test repository access
# Verify user accounts
# Check CI/CD functionality
```

### Phase 6: Post-Incident

#### Documentation Requirements
```markdown
## Incident Report Template

**Incident ID:** INC-$(date +%Y%m%d)-001
**Date/Time:** $(date)
**Severity:** [1-4]
**Status:** [Open/Investigating/Contained/Resolved/Closed]

### Summary
Brief description of the incident.

### Timeline
- **Time Detected:** 
- **Containment Actions:** 
- **Investigation Steps:** 
- **Resolution Time:** 
- **Closure Time:** 

### Root Cause Analysis
Primary cause of the incident.

### Impact Assessment
- Affected Systems:
- Data Compromised:
- Service Downtime:
- Reputation Impact:

### Actions Taken**
1. Immediate containment
2. Evidence collection
3. Investigation
4. Eradication
5. Recovery
6. Prevention

### Lessons Learned**
Key takeaways and improvements.

### Prevention Measures**
Concrete steps to prevent recurrence.

### Sign-off**
- Investigator: 
- Reviewer: 
- Approved by: 
```

#### Improvement Implementation
1. **Process Updates**
   - Update OPERATIONS.md with lessons learned
   - Modify SECURITY.md with new procedures
   - Enhance monitoring based on gaps identified

2. **Technical Improvements**
   - Implement additional security controls
   - Update backup procedures
   - Enhance logging and monitoring

3. **Training Updates**
   - Update team training materials
   - Conduct incident response drills
   - Share lessons learned

## Specific Incident Scenarios

### Scenario 1: Unauthorized Access Attempt

#### Detection
```bash
# Log monitoring shows:
tail /var/log/auth.log
# Feb 15 12:32:01 server sshd[1234]: Failed password for root from 192.168.1.100 port 22 ssh2
# Multiple failed attempts from same IP
```

#### Response
```bash
# 1. Immediate Block
iptables -A INPUT -s 192.168.1.100 -j DROP

# 2. Log Preservation
cp /var/log/auth.log /tmp/incident_ssh_attack_$(date +%s).log

# 3. Investigation
last | grep -i "192.168.1.100"
who

# 4. Notification
# Alert CTO Veld via Discord DM
# Document in MEMORY.md
```

#### Prevention
```bash
# Implement fail2ban
apt install fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Review SSH configuration
nano /etc/ssh/sshd_config
# Set: PermitRootLogin prohibit-password
# Set: MaxAuthTries 3
# Set: PasswordAuthentication no
```

### Scenario 2: Gitea Service Compromise

#### Detection
```bash
# Service unresponsive
curl http://localhost:3000/ -s -o /dev/null -w "%{http_code}"
# Returns non-200

# Log shows unauthorized changes
journalctl -u gitea | grep -i "unauthorized\|malicious\|inject"
```

#### Response
```bash
# 1. Immediate Isolation
systemctl stop gitea
iptables -A INPUT -p tcp --dport 3000 -j DROP

# 2. Evidence Collection
cp -r /opt/gitea/data /tmp/gitea_compromise_$(date +%s)/
ps aux | grep gitea > /tmp/gitea_processes.txt

# 3. Backup Verification
# Check for clean backup
ls -la /opt/gitea/data.backup/

# 4. Restoration
systemctl stop gitea
rm -rf /opt/gitea/data
cp -r /opt/gitea/data.backup/clean/ /opt/gitea/data/
systemctl start gitea

# 5. Security Review
find /opt/gitea -type f -exec grep -l "eval\|base64\|wget\|curl" {} \;
```

### Scenario 3: Identity Conflict (Gerard Impersonator)

#### Detection
```bash
# Multiple Gerard accounts detected
# "Gerard (emoji)" vs "Gerard" (ssmmiles)
# CTO Veld verification required
```

#### Response
```bash
# 1. Account Freeze
# Temporarily suspend all Gerard accounts
# Require re-authentication

# 2. Verification Process
# Contact CTO Veld for confirmation
# Cross-reference known identifiers
# Check historical decision patterns

# 3. Resolution
# Confirm real Gerard (ssmmiles)
# Mark impersonator as bug/security issue
# Update MEMORY.md with verification

# 4. Prevention
# Implement multi-factor authentication
# Require secondary verification for critical operations
# Regular identity audits
```

### Scenario 4: Competitor Interference (Xavin)

#### Detection
```bash
# Unusual migration failures
# System instability during critical operations
# Pattern matches known competitor tactics
```

#### Response
```bash
# 1. Documentation
# Log all suspicious activity
# Preserve evidence of interference

# 2. Operational Continuity
# Switch to manual procedures
# Implement additional verification steps

# 3. Countermeasures
# Increase monitoring of critical systems
# Implement anomaly detection
# Regular security audits

# 4. Communication
# Alert CEO Gerard and CTO Veld
# Document in SECURITY.md
# Update competitor awareness protocols
```

## Communication Protocols

### Internal Communication
- **Discord DMs**: Primary for sensitive discussions
- **MEMORY.md**: Incident documentation
- **company-structure repository**: Formal documentation

### External Communication
- **None currently**: No public disclosure required
- **Future consideration**: Status page for public services

### Notification Templates

#### SEVERITY 1 Alert
```
[URGENT] SEVERITY 1 INCIDENT DETECTED

Incident: [Brief Description]
Time: [Detection Time]
Systems Affected: [List]
Current Status: [Investigating/Contained]

Immediate Actions:
1. [Action 1]
2. [Action 2]
3. [Action 3]

Required: [Who needs to respond]
Next Update: [When]
```

#### SEVERITY 2 Alert
```
[HIGH PRIORITY] SEVERITY 2 INCIDENT

Incident: [Brief Description]
Time: [Detection Time]
Impact: [Estimated Impact]
Status: [Under Investigation]

Actions Taken:
1. [Action 1]
2. [Action 2]

Next Steps:
1. [Step 1]
2. [Step 2]

Update Expected: [Time]
```

### Post-Incident Communication
1. **Initial Resolution Notification**
   - Brief summary of resolution
   - Services restored status
   - Estimated time for full report

2. **Detailed Incident Report**
   - Root cause analysis
   - Impact assessment
   - Actions taken
   - Prevention measures

3. **Lessons Learned Meeting**
   - Review with all stakeholders
   - Identify process improvements
   - Update documentation

## Testing and Drills

### Quarterly Incident Response Test
1. **Schedule**: First week of each quarter
2. **Scenario**: Randomly selected from playbook
3. **Participants**: All technical team members
4. **Duration**: 2 hours maximum
5. **Evaluation**: Based on response time, completeness, documentation

### Monthly Tabletop Exercise
1. **Schedule**: Last Friday of each month
2. **Format**: Discussion-based scenario walkthrough
3. **Focus**: Communication and coordination
4. **Outcome**: Updated procedures and training

### Weekly Monitoring Review
1. **Schedule**: Every Monday
2. **Focus**: Review recent alerts and incidents
3. **Action**: Update monitoring rules based on findings
4. **Documentation**: Update OPERATIONS.md

## Continuous Improvement

### Metrics Tracking
```bash
# Incident Response Metrics
# Time to Detection (TTD)
# Time to Containment (TTC)
# Time to Resolution (TTR)
# Incident Recurrence Rate
# Prevention Effectiveness
```

### Process Updates
- Monthly review of all incidents
- Quarterly update of playbooks
- Annual comprehensive review
- Immediate updates after major incidents

### Training Updates
- Incorporate lessons learned into training
- Update onboarding procedures
- Share insights across team
- Maintain institutional knowledge

---

### Scenario 5: Backup Failure or Data Corruption

#### Detection
```bash
# Scheduled backup script or manual verification reports errors
ls -lah /opt/gitea/data.backup/daily | tail
md5sum -c /opt/gitea/data.backup/checksums.md5
```

#### Response
```bash
# 1. Identify last known-good backup
ls -dt /opt/gitea/data.backup/daily/* | head

# 2. Preserve failing backup set for forensics
cp -r /opt/gitea/data.backup/daily/$(date +%Y%m%d) /tmp/backup_failure_$(date +%s)/

# 3. Re-run backup with verbose logging
/opt/scripts/daily-backup.sh | tee /tmp/backup_retry.log

# 4. Validate integrity
find /opt/gitea/data -type f -exec md5sum {} \; > /tmp/data_current.md5
diff /tmp/data_current.md5 /opt/gitea/data.backup/latest/checksums.md5
```

#### Prevention
- Add checksum file generation after every backup
- Monitor free disk space before running jobs
- Schedule monthly restore tests (OPERATIONS.md) and log results in MEMORY.md

### Scenario 6: Resource Exhaustion / Service Degradation

#### Detection
```bash
# Elevated CPU or memory usage
uptime
free -h
top -bn1 | head -20

# Gitea latency
curl -w "Total: %{time_total}\n" -o /dev/null http://localhost:3000/
```

#### Response
```bash
# 1. Identify heavy processes
ps aux --sort=-%mem | head
ps aux --sort=-%cpu | head

# 2. Capture diagnostics
sar -u 1 5 > /tmp/cpu_sar.txt
sar -r 1 5 > /tmp/mem_sar.txt

# 3. Mitigation options
systemctl restart gitea  # Only if safe and authorized
swapoff -a && swapon /swapfile  # After creating swapfile per TECHNICAL.md plan
```

#### Prevention
- Implement swapfile (2 GiB) and resource monitoring alerts
- Optimize CI builds to run off-peak
- Track average load in MEMORY.md to detect trends

### Scenario 7: Identity Verification Crisis (Authority Conflict)

#### Detection Indicators
- Multiple individuals claiming same identity/role
- Contradictory directives from purported authority figures
- Verification failure through established channels
- Evidence of impersonation attempts

#### Response Protocol
```bash
# 1. IMMEDIATE FREEZE
# Freeze all accounts related to conflicting identities
# Suspend all privileged operations requiring verification
# Preserve chat logs, directives, and evidence

# 2. EVIDENCE COLLECTION
# Archive Discord/communication logs
# Capture screenshot evidence of conflicting claims
# Document timestamps and exact statements
mkdir -p /tmp/identity_crisis_$(date +%Y%m%d_%H%M%S)

# 3. VERIFICATION ESCALATION
# Contact ONLY previously verified authority (CTO Veld)
# Use established secure channels (Discord DM with verification history)
# Require multi-factor confirmation: 
#   - Previous decision references
#   - Knowledge of specific shared history
#   - Secure token exchange if available

# 4. CONTAINMENT ACTIONS
if [ "$CONFLICT_RESOLUTION" = "Veld_confirmed" ]; then
    # Follow Veld directives explicitly
    # Document resolution in MEMORY.md
    # Update SECURITY.md authority chain
    # Implement any account revocations
elif [ "$CONFLICT_RESOLUTION" = "Gerard_confirmed" ]; then
    # Requires extraordinary evidence
    # Cross-reference with previous verification records
    # Contact Veld for secondary confirmation
    # If confirmed, update authority documentation
else
    # Maintain freeze until resolution
    # Escalate to external arbitration if needed
    # Preserve all evidence for investigation
fi
```

#### Investigation Steps
1. **Historical Analysis**
   - Review MEMORY.md for previous verification events
   - Check git commit history for authority patterns
   - Analyze communication channel security

2. **Technical Forensics**
   - Check IP addresses and connection patterns
   - Verify cryptographic signatures if available
   - Analyze timing of conflicting directives

3. **Behavioral Analysis**
   - Compare communication styles
   - Verify knowledge of internal systems
   - Cross-reference with known operational patterns

#### Resolution Protocol
1. **Authority Confirmation**
   - Single source of truth established
   - All team members notified of resolution
   - Documentation updated immediately

2. **Account Management**
   - Revoke unauthorized accounts
   - Rotate all credentials and secrets
   - Implement enhanced verification for future

3. **Process Improvement**
   - Update identity verification procedures
   - Implement multi-person confirmation for critical changes
   - Establish escalation hierarchy with fallback contacts

#### Prevention Measures
- **Multi-person verification**: Require 2+ trusted authorities for sensitive operations
- **Emergency contact protocol**: Designated fallback contacts outside usual chain
- **Immutable audit trail**: All authority changes logged in git with cryptographic signatures
- **Regular verification drills**: Quarterly identity confirmation exercises
- **Secure communication channels**: Encrypted, logged channels for sensitive directives

---

*This playbook is a living document. Update after every incident and during quarterly reviews. All team members must be familiar with their roles and responsibilities.*
