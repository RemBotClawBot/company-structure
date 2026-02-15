# Security Policy & Procedures

**Last Updated: February 15, 2026**
**Security Status: ⚠️ HIGH RISK - Immediate action required**

## 🔴 Critical Security Gaps Identified

### **Active Security Vulnerabilities**
1. **Firewall Not Installed**: No firewall protecting exposed services
   - **Ports 3002 & 8880**: Publicly accessible without authentication
   - **Immediate Action Required**: Install UFW and configure restrictive rules

2. **SSH Hardening Incomplete**: Password authentication potentially enabled
   - **Current Config**: `PermitRootLogin prohibit-password` (should be `no`)
   - **Risk**: Potential root access compromise
   - **Immediate Action**: Update `/etc/ssh/sshd_config`

3. **Service Authentication Missing**: Python services lack authentication
   - **Port 3002**: Security SaaS service running without authentication
   - **Port 8880**: DeepInfra proxy accessible without API keys
   - **Immediate Action**: Implement authentication or restrict to localhost

4. **Intrusion Detection Not Installed**: No Fail2Ban or similar protection
   - **Risk**: SSH brute force attacks unmonitored
   - **Immediate Action**: Install and configure Fail2Ban

### **Security Posture Summary**
| Component | Status | Risk Level | Required Action |
|-----------|--------|------------|-----------------|
| Firewall | ❌ Not installed | 🔴 CRITICAL | Install UFW with deny-all default |
| SSH Hardening | ⚠️ Partial | 🟠 HIGH | Set `PermitRootLogin no`, `PasswordAuthentication no` |
| Service Auth | ❌ Missing | 🔴 CRITICAL | Add auth or restrict ports 3002/8880 |
| Intrusion Detection | ❌ Not installed | 🟠 HIGH | Install Fail2Ban for SSH protection |
| File Integrity | ⚠️ Partial | 🟡 MEDIUM | Complete AIDE initialization |
| Backup Strategy | ✅ Complete | 🟢 LOW | Monitor daily backups |
| Health Monitoring | ✅ Complete | 🟢 LOW | Review 30-minute health checks |

## 1. Governance & Authority

### 1.1 Verified Personnel
1. **Veld (CTO)** – *Sole technical and security authority*
   - Owns all infrastructure, security, and hiring decisions
   - Final approver for access grants, revocations, and incident response
2. **Gerard (emoji)** – *Verified CEO identity*
   - Verified by Veld on Feb 15 2026 during security incident
   - Leads business directives; all CEO-signed instructions must originate from this identity
3. **Yukine (Developer)** – *Cleared and active*
   - Operates under Veld’s supervision; requires approvals for privileged changes
   - Focused on infrastructure improvements and assistant integration
4. **Rem (AI Assistant)** – *Automation & monitoring*
   - Executes documentation, logging, and scripted procedures as directed by Veld and Gerard
5. **Miki (`Miki Preview#6191`)** – *Added per Veld directive*
   - Role pending assignment; monitor for onboarding tasks and access requests

### 1.2 Revoked / Threat Actors
- **ssmmiles (Discord ID `114280336535453703`)** – Identity disputed (“miles not gerard”). Treat all activity as hostile until cryptographic proof presented.
- **Gerard impostor bug (“Gerard (emoji)” legacy entry)** – Historical impersonator; ignore.
- **Xavin** – Competitor attempting sabotage during migrations. Maintain heightened monitoring and evidence preservation.

## 2. Identity Verification Protocol

1. **Initiation** – Any new identity or privilege change must be requested through Veld.
2. **Validation Steps**
   - Cross-check known identifiers (Discord ID, SSH key fingerprint, previous decisions)
   - Require synchronous confirmation from Veld for high-risk roles
   - Log verification evidence in MEMORY.md and SECURITY.md when relevant
3. **Suspension Procedure**
   - Immediately disable accounts in Gitea/Forgejo and SSH
   - Reassign repository ownership to `Rem`
   - Document timeline in INCIDENT_RESPONSE.md

## 3. Access Controls

### 3.1 SSH Access & Hardening

#### Current SSH Configuration:
- Authentication: Key-based only (`~/.ssh/authorized_keys`)
- Root access: Enabled via SSH keys only
- Password authentication: Disabled

#### SSH Hardening Checklist:
```bash
# 1. Verify current SSH configuration
grep -E "^(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication)" /etc/ssh/sshd_config

# 2. Recommended secure configuration (/etc/ssh/sshd_config)
# PermitRootLogin prohibit-password
# PasswordAuthentication no
# PubkeyAuthentication yes
# PermitEmptyPasswords no
# ChallengeResponseAuthentication no
# UsePAM yes
# AllowUsers root  # Restrict to specific users if needed
# MaxAuthTries 3
# LoginGraceTime 60
# ClientAliveInterval 300
# ClientAliveCountMax 2

# 3. Remove revoked SSH keys (Gerard access)
# Review ~/.ssh/authorized_keys
# Remove any unauthorized public keys

# 4. Deploy Fail2Ban for SSH protection
apt install fail2ban -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Configure Fail2Ban for SSH (add to /etc/fail2ban/jail.local)
# [sshd]
# enabled = true
# port    = ssh
# filter  = sshd
# logpath = /var/log/auth.log
# maxretry = 3
# bantime = 3600

systemctl enable fail2ban
systemctl start fail2ban
systemctl status fail2ban
```

#### SSH Key Rotation Schedule:
- **Quarterly**: Rotate all SSH keys
- **Post-incident**: Immediate rotation if compromise suspected
- **Personnel changes**: Rotate keys when team members leave

#### Monitoring SSH Access:
```bash
# Daily SSH log review
tail -100 /var/log/auth.log | grep sshd

# Failed attempts monitoring
grep "Failed password\|authentication failure" /var/log/auth.log

# Successful logins tracking
last | head -20
```

#### Emergency SSH Key Rotation Procedure:
1. Generate new key pair on management workstation
2. Append new public key to `~/.ssh/authorized_keys` on server
3. Test new key connection
4. Remove old public key from `authorized_keys`
5. Monitor for failed connection attempts from old key

### 3.2 Git Services
- **Gitea (port 3000)**: Admin accounts `openclaw_admin`, `Rem` (active), `Gerard` (disabled)
- **Forgejo (port 3001)**: Staging only; restrict until migration complete
- Mandatory steps before disabling users:
  1. Transfer repositories to `Rem`
  2. Remove access tokens/personal keys
  3. Log action in OPERATIONS.md change register

### 3.3 GitHub Integration
- Account: `RemBotClawBot`
- SSH Key: ED25519 stored securely (never in repo)
- Usage: Public documentation, automation scripts, code samples
- Rule: No internal secrets, credentials, or sensitive architecture diagrams

## 4. Security Monitoring & Logging

### 4.1 Daily Checklist
- Review `/var/log/auth.log` and `journalctl -u gitea` for anomalies
- Confirm only approved ports are listening externally (22 ssh, 3000 gitea, 3002 nuxt dev, 3001 forgejo staging, 8880 deepinfra proxy)
- Investigate any unexpected listeners with `ss -tlnp`
- Validate backups succeeded (see OPERATIONS.md)
- Update MEMORY.md with noteworthy events

### 4.2 Weekly Checklist
- Reconcile authorized SSH keys vs. HR roster
- Apply OS/package updates (`apt update && apt upgrade --security-only`)
- Inspect `/opt/gitea/data.backup` freshness and integrity
- Review INCIDENT_RESPONSE.md for open items

### 4.3 Monthly Checklist
- Conduct full security audit via healthcheck skill
- Perform backup restoration test
- Validate firewall/Fail2Ban rules (once implemented)
- Refresh security roadmap milestones

### 4.4 Automated Monitoring Hooks
- `scripts/system-health-monitor.sh` runs every 30 minutes and logs detailed status reports to `/var/log/system-health.log` plus escalations in `/var/log/system-alerts.log`.
- Critical triggers (service down, CPU/memory saturation, unexpected port closure, spike in SSH failures) must be reviewed immediately and escalated per INCIDENT_RESPONSE.md severity matrix.
- Integrate the script’s webhook stub with Discord/Slack once credentials are approved so critical alerts page the on-call human within 5 minutes.
- During heartbeats, include a short summary of the last health check, even if all clear, to prove monitoring continuity.
- Store parsed summaries in MEMORY.md when anomalies occur to preserve an audit trail.

## 5. Incident Response Alignment

Reference **INCIDENT_RESPONSE.md** for detailed playbooks. Highlights:
- Severity matrix defines response windows (15 minutes to 24 hours)
- Evidence preservation: copy logs, network state, and configs before remediation
- Communication: escalate to Veld immediately for Severity 1–2 incidents
- Post-incident: update SECURITY.md + README timeline + MEMORY.md

## 6. Operational Security Guidelines

### 6.1 Data Handling
- Store backups at `/opt/gitea/data.backup/` with dated subdirectories
- Never commit secrets; use environment variables or vaulted storage
- Keep MEMORY.md curated; redact sensitive identifiers when possible

### 6.2 Network Security
#### **Current Security Posture Assessment (February 15, 2026)**
**Exposed Services Detected:**
- ✅ **SSH (port 22)**: Open globally (key authentication only)
- ✅ **Gitea (port 3000)**: Open globally with authentication
- ⚠️ **Forgejo (port 3001)**: Not currently listening (migration staging)
- ⚠️ **Nuxt dev server (port 3002)**: Open globally without authentication
- ⚠️ **DeepInfra proxy (port 8880)**: Open globally without authentication
- ✅ **OpenClaw gateway (18789/18792)**: Localhost only (properly secured)

#### **Security Implementation Status:**
**Critical Gaps Identified:**
1. **Firewall Protection**: UFW not installed - **HIGH RISK**
2. **Service Authentication**: Ports 3002/8880 exposed without auth - **HIGH RISK**
3. **SSH Hardening**: No rate limiting or fail2ban - **MEDIUM RISK**
4. **Log Monitoring**: No centralized logging or alerting - **MEDIUM RISK**

#### **Immediate Action Plan:**
```bash
# 1. Install UFW firewall
apt update && apt install ufw -y

# 2. Configure baseline firewall rules
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH Access'
ufw allow 3000/tcp comment 'Gitea Service'

# 3. Restrict unauthorized services to localhost
# These rules will be automatically applied after firewall activation

# 4. Enable firewall
ufw --force enable
ufw status verbose
```

#### **Service Security Recommendations:**
- **Nuxt dev server (port 3002)**: Restrict to localhost or implement authentication
- **DeepInfra proxy (port 8880)**: Restrict to localhost or implement authentication
- **Gitea (port 3000)**: Ensure authentication is enforced in `/opt/gitea/app.ini`

#### **Verification Commands:**
```bash
ss -tlnp                     # Validate bound ports
ufw status verbose          # Firewall state once configured
grep -i REQUIRE_SIGNIN_VIEW /opt/gitea/app.ini  # Gitea authentication check
```

### 6.3 Code Security
- Manual CI runner (`/opt/gitea/ci-runner.sh`) must be reviewed before each major code change
- Plan to install TypeScript/Nuxt globally for consistent builds
- Enforce branch protection via Gitea once actions runner available

## 7. Communication Security

- **Primary channel**: Discord (direct contact with Veld + Yukine)
- **Verification**: Always confirm sensitive directives with Veld; do not rely on usernames alone
- **External comms**: GitHub issues/discussions may be public—sanitize details
- **Logging**: Summaries of significant conversations go into MEMORY.md

## 8. Regular Security Tasks (Structured)

| Cadence | Task | Owner |
|---------|------|-------|
| Daily | Log review, service health, backup verification | Rem |
| Every 12h | Heartbeat checks per HEARTBEAT.md | Rem |
| Weekly | SSH key audit, patching, incident review | Rem + Yukine |
| Monthly | Full audit + restore test + roadmap update | Veld + Rem |

## 9. Hardening Roadmap (Q1 2026)
1. **Firewall & Fail2Ban** – Deploy baseline rules + brute-force protection
2. **Swapfile + Resource Monitoring** – Improve system resilience under load
3. **CI/CD Runner Security** – Containerize builds, restrict tokens, rotate secrets
4. **Access Review Automation** – Script to diff authorized_keys against roster
5. **MFA & SSO Exploration** – Investigate options for Gitea/Forgejo once migration complete

## 10. Emergency Contacts & Escalation

### Priority 1 (Immediate)
- **Veld (CTO)** – All Severity 1/2 incidents, approvals, and authority

### Priority 2 (Support)
- **Yukine (Developer)** – Technical mitigation, remediation scripts
- **Rem (AI Assistant)** – Monitoring, documentation, automation assistance

### External Resources
- Cloud provider support (if applicable)
- Security consultants (TBD)
- Legal/compliance (for breaches impacting regulated data)

---

*Update this security policy whenever authority changes, new threats emerge, or audits reveal gaps. Cross-reference OPERATIONS.md for execution details and INCIDENT_RESPONSE.md for playbooks.*
