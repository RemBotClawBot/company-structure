# Incident Response Playbook

## Table of Contents
1. [Incident Classification](#incident-classification)
2. [Response Team](#response-team)
3. [Severity Levels](#severity-levels)
4. [Immediate Actions](#immediate-actions)
5. [Investigation Procedures](#investigation-procedures)
6. [Containment Measures](#containment-measures)
7. [Eradication & Recovery](#eradication-recovery)
8. [Post-Incident Activities](#post-incident-activities)
9. [Communication Protocols](#communication-protocols)
10. [Evidence Preservation](#evidence-preservation)
11. [Reporting Templates](#reporting-templates)

## Incident Classification

### Category 1: Security Incidents
- Unauthorized access attempts
- Account compromise
- Data breaches
- Malware infections
- DDoS attacks

### Category 2: Infrastructure Incidents
- Service outages
- Performance degradation
- Configuration errors
- Hardware failures
- Network issues

### Category 3: Identity/Authority Incidents
- Identity verification failures
- Authority disputes
- Access privilege abuse
- Account hijacking
- Fraudulent activity

### Category 4: Operational Incidents
- Backup failures
- Monitoring system failures
- Documentation inconsistencies
- Process violations
- Communication breakdowns

## Response Team

### Primary Responders
| Role | Responsibilities | Contact |
|------|-----------------|---------|
| **Incident Commander** | Overall coordination, decision making | Veld |
| **Technical Lead** | Technical investigation, containment | Yukine |
| **Security Analyst** | Forensics, evidence collection | Rem |
| **Communications Lead** | Stakeholder communication | Gerard |

### Escalation Chain
1. **Level 1**: Automated detection (Rem monitoring)
2. **Level 2**: On-call technical team (Yukine)
3. **Level 3**: Incident Commander (Veld)
4. **Level 4**: Executive review (Gerard)

## Severity Levels

### Severity 1 (Critical)
- **Definition**: Complete service outage, unauthorized root access, data breach
- **Response Time**: Immediate (<5 minutes)
- **Escalation**: All hands, CTO notified immediately
- **Examples**: Production system compromise, ransomware attack

### Severity 2 (High)
- **Definition**: Partial service disruption, suspicious activity, potential breach
- **Response Time**: <30 minutes
- **Escalation**: Technical team + Incident Commander
- **Examples**: Unauthorized access attempts, privilege escalation

### Severity 3 (Medium)
- **Definition**: Performance issues, configuration errors, minor security events
- **Response Time**: <2 hours
- **Escalation**: Technical team lead
- **Examples**: Login failures, backup failures, monitoring alerts

### Severity 4 (Low)
- **Definition**: Informational alerts, routine maintenance, documentation updates
- **Response Time**: <24 hours
- **Escalation**: Automated response or on-call technician
- **Examples**: Log analysis findings, minor policy violations

## Immediate Actions

### For All Incidents
1. **Assess**: Determine severity level and incident category
2. **Contain**: Isolate affected systems
3. **Document**: Start incident log with timestamp
4. **Notify**: Alert response team based on severity

### Security Incident Checklist
```
☐ 1. Identify affected systems
☐ 2. Disconnect from network if compromised
☐ 3. Change credentials for affected accounts
☐ 4. Capture memory and process information
☐ 5. Preserve logs and evidence
☐ 6. Notify Incident Commander
☐ 7. Begin forensic analysis
```

### Infrastructure Incident Checklist
```
☐ 1. Identify root cause
☐ 2. Check backup availability
☐ 3. Assess impact scope
☐ 4. Implement workaround if available
☐ 5. Notify affected users/stakeholders
☐ 6. Begin recovery procedures
```

## Investigation Procedures

### Step 1: Evidence Collection
```bash
# Capture system state
systemctl status --all > /tmp/incident-systemctl-status.txt
ps auxf > /tmp/incident-process-list.txt
netstat -tulpn > /tmp/incident-network-connections.txt

# Capture logs
journalctl --since "1 hour ago" > /tmp/incident-journal.log
tail -1000 /var/log/syslog > /tmp/incident-syslog.txt
tail -1000 /var/log/auth.log > /tmp/incident-auth.log

# Capture user activity
last > /tmp/incident-last-logins.txt
who > /tmp/incident-current-users.txt

# File integrity checks
ls -la /opt/gitea/ > /tmp/incident-gitea-files.txt
ls -la /root/company-structure/ > /tmp/incident-docs-files.txt
```

### Step 2: Timeline Analysis
1. Review system logs for anomalies
2. Check user authentication attempts
3. Examine file modification times
4. Correlate events across systems
5. Identify attack vectors

### Step 3: Root Cause Analysis
1. Determine initial access method
2. Identify exploited vulnerabilities
3. Map attacker movements
4. Assess data exposure
5. Document attack timeline

## Containment Measures

### Network Containment
```bash
# Isolate compromised systems
ufw deny from <compromised_ip>
ufw deny to <compromised_ip>

# Block malicious traffic
iptables -A INPUT -s <malicious_ip> -j DROP
iptables -A OUTPUT -d <malicious_ip> -j DROP
```

### Account Containment
```bash
# Lock compromised accounts
passwd -l <username>
usermod -L <username>

# Remove SSH keys
rm -f /home/<username>/.ssh/authorized_keys
```

### Service Containment
```bash
# Stop compromised services
systemctl stop <compromised_service>

# Disable service auto-start
systemctl disable <compromised_service>
```

## Eradication & Recovery

### Malware Removal
1. Identify malicious files and processes
2. Remove persistence mechanisms
3. Clean infected configuration files
4. Update all security software
5. Apply security patches

### System Recovery
1. Restore from clean backups
2. Rebuild compromised systems
3. Reinstall affected software
4. Apply security hardening
5. Validate system integrity

### Credential Rotation
1. Rotate all SSH keys
2. Change system passwords
3. Update API tokens and secrets
4. Revoke compromised certificates
5. Enable MFA where available

## Post-Incident Activities

### Lessons Learned Session
1. Review incident timeline
2. Identify gaps in detection/response
3. Assess effectiveness of procedures
4. Document improvements needed
5. Update documentation and playbooks

### Improvement Implementation
1. Address identified vulnerabilities
2. Implement monitoring improvements
3. Update security policies
4. Enhance response procedures
5. Conduct training as needed

## Communication Protocols

### Internal Communications
- **Slack/Discord**: #security-incidents channel
- **Email**: security@company.com for formal communications
- **Phone**: Emergency contact list for after-hours incidents

### External Communications
- **Customers**: Transparent status updates
- **Legal**: Compliance with breach notification laws
- **Media**: Prepared statement from communications lead
- **Regulators**: Required breach notifications

### Reporting Templates

#### Initial Incident Report
```
INCIDENT REPORT - INITIAL
Time: [Timestamp]
Severity: [Level 1-4]
Category: [Security/Infrastructure/Identity/Operational]
Systems Affected: [List]
Current Status: [Investigating/Contained/Recovered]
Action Taken: [Brief summary]
Next Steps: [Immediate planned actions]
```

#### Post-Incident Report
```
POST-INCIDENT REPORT
Incident ID: [Reference]
Date: [Start-End]
Severity: [Level]
Root Cause: [Analysis]
Impact: [Affected systems/data]
Resolution: [Actions taken]
Lessons Learned: [Improvements identified]
Preventative Measures: [Changes implemented]
```

## Evidence Preservation

### Collection Procedures
1. **Digital Evidence**: System logs, network captures, memory dumps
2. **Physical Evidence**: Server logs, access logs, configuration files
3. **Chain of Custody**: Document handling procedures

### Storage Requirements
- Store evidence in `/var/evidence/[incident-id]/`
- Use write-once media when possible
- Maintain integrity controls (hash values)
- Limit access to response team only

### Legal Considerations
- Consult legal counsel for regulatory requirements
- Preserve evidence for potential legal proceedings
- Document all actions for audit trail
- Follow data retention policies

---

## Incident Response Checklist

### Phase 1: Detection & Analysis
- [ ] Confirm incident occurrence
- [ ] Classify incident type and severity
- [ ] Notify Incident Commander
- [ ] Begin evidence collection
- [ ] Document initial observations

### Phase 2: Containment
- [ ] Isolate affected systems
- [ ] Implement temporary fixes
- [ ] Preserve evidence
- [ ] Update stakeholders
- [ ] Prevent further damage

### Phase 3: Eradication
- [ ] Remove malware/backdoors
- [ ] Identify root cause
- [ ] Patch vulnerabilities
- [ ] Rotate credentials
- [ ] Validate clean state

### Phase 4: Recovery
- [ ] Restore services from backup
- [ ] Test system functionality
- [ ] Monitor for recurrence
- [ ] Update security controls
- [ ] Document recovery steps

### Phase 5: Post-Incident
- [ ] Conduct lessons learned
- [ ] Update incident documentation
- [ ] Implement improvements
- [ ] Schedule follow-up review
- [ ] Archive incident records

---

*This playbook should be reviewed quarterly and updated based on lessons learned from incidents.*