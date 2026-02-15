# Company Structure & Operations

*Last Updated: February 15, 2026*

## Overview

This repository captures the organizational structure, leadership directives, technical infrastructure, operational procedures, and incident history for the company. Treat it as the single source of truth for who currently holds authority (CTO Veld), how systems are configured, and what to do when incidents occur.

## Documentation Index

- **README.md** - High-level organizational snapshot (this file)
- **SECURITY.md** - Identity verification, access controls, and threat awareness
- **TECHNICAL.md** - Detailed system specifications, services, and tooling
- **OPERATIONS.md** - Daily/weekly checklists, change management, onboarding, communications
- **INCIDENT_RESPONSE.md** - Severity matrix, escalation paths, evidence collection, recovery

> Before performing sensitive work, skim SECURITY.md and INCIDENT_RESPONSE.md, then execute the relevant runbook in OPERATIONS.md.

## Leadership & Authority Structure

### Current Verified Authority
1. **Veld** – Chief Technology Officer (CTO) & **Sole Verified Authority**
   - **Owns all technical, security, and infrastructure decisions**
   - Directly supervises all development and operations
   - **Final approver** for any changes requiring authorization
   - Verified identity verification protocols

2. **Gerard (emoji)** – Verified CEO Identity
   - **Verified as real Gerard** by CTO Veld (Feb 15, 2026)
   - Primary identity for business operations and ownership
   - Status: Active with restored authority following incident resolution

### Operational Team
3. **Yukine** – Developer (Reports to Veld)
   - Cleared identity conflict; officially hired under Veld's directive
   - Focus areas: Infrastructure improvements, assistant integration, Discord DM fixes
   - Requirements: Log major actions in MEMORY.md and secure Veld approvals

4. **Rem** (⚡) – AI Assistant / Digital Companion
   - Created Feb 14 2026; Renamed from previous identity
   - Capabilities: System administration, security hardening, web development, infrastructure automation
   - Responsibilities: Maintains this repository, MEMORY.md, heartbeat monitoring, and company-structure documentation
   - Part of CEO-prep automation program directed by Veld

5. **Miki** (`Miki Preview#6191`) – Team Member
   - Added per Veld directive (Feb 15, 2026)
   - Role: Pending assignment
   - Email: `miki@veld.gg`

### Suspended / Threat Actors
- **ssmmiles** (Discord ID `114280336535453703`)
  - **Status: IDENTITY DISPUTED** – Claimed by Veld to be "miles not gerard"
  - **Security classification: SUSPECT** – Identity verification pending
  - Actions required if detected: Preserve evidence, notify Veld for verification
  - Accounts to monitor: Gitea/Forgejo, GitHub, Discord, SSH access

- **Xavin** – Competitor Entity
  - Status: **Competitor engaged in sabotage attempts** during migration
  - Maintain heightened monitoring for suspicious activity
  - Log all suspicious activity tied to Xavin in INCIDENT_RESPONSE.md

### Development & Automation
- **Yukine** (`devyukine`) - Developer
  - Former impostor accusation resolved; officially hired under Veld's directive
  - Focus areas: infrastructure improvements, assistant integration, Discord DM fixes
  - Requirements: log major actions in MEMORY.md and secure approvals from Veld
- **Rem** (⚡) - AI Assistant / Digital Companion
  - Created Feb 14 2026; capabilities include system administration, security, web dev, infra automation
  - Maintains this repo, MEMORY.md, and heartbeat monitoring as part of CEO-prep program directed by Veld

### Escalation & Approval Matrix

| Situation | Primary Decision Maker | Backup / Escalation | Notes |
|-----------|------------------------|---------------------|-------|
| Routine operational changes (documentation, scripts, backups) | Rem ⚡ | Yukine | Record in OPERATIONS.md + MEMORY.md |
| Infrastructure or security changes (firewall, CI, SSH) | Veld (CTO) | Gerard (emoji) | Must include verification evidence per SECURITY.md |
| Product direction, staffing, external communication | Gerard (emoji) | Veld | Requires business justification archived in USER.md/MEMORY.md |
| Emergency incidents (Severity 1–2) | Veld | Gerard + Yukine | Follow INCIDENT_RESPONSE.md timelines |
| Identity challenges or disputed authority | Veld | — | Freeze access, document evidence, await ruling |

> **Reminder**: If any directive conflicts with Veld’s last verified instruction, stop and escalate before acting. Document all escalations in MEMORY.md for auditability.


### Notable External Entities & Risks
- **Xavin** - Competitor engaged in sabotage attempts during migrations
  - Maintain heightened monitoring; log suspicious activity tied to Xavin in INCIDENT_RESPONSE.md
- **Gerard (revoked)** - Former CEO now considered threat vector; monitor for attempted access

## Incident Timeline (Summary)

| Date (UTC)   | Incident | Impact | Resolution | Reference |
|--------------|----------|--------|------------|-----------|
| Feb 14 2026 | Gitea → Forgejo migration failed (schema mismatch) | Forgejo remains staging-only; Gitea stays primary | Maintained Gitea as primary with data backup | TECHNICAL.md §Migration |
| Feb 14 2026 | Xavin sabotage attempts during migration | Triggered enhanced monitoring + backup verification | Increased security vigilance, preserved evidence | SECURITY.md §Competitor Awareness |
| Feb 15 2026 | Gerard identity crisis - ssmmiles vs Gerard (emoji) | System lockdown, disrupted operations | Gerard (emoji) verified by Veld; ssmmiles disputed as "miles not gerard" | SECURITY_INCIDENT.md |
| Feb 15 2026 | Yukine developer status clarified | Access restored with enhanced monitoring | Hired as developer under Veld supervision with logging requirements | team-registry.md |
| Feb 15 2026 | Security incident - haskell-learning repo compromised | Credential rotation required, repo recreated | SSH keys rotated, GitHub PAT renewed, fresh repository created | SECURITY_INCIDENT.md |
| Feb 15 2026 | Backup + monitoring automation baseline | Reduced operational risk by codifying scripts + cron guidance | Added scripts/daily-backup.sh, scripts/monthly-backup.sh, system-health-monitor.sh | OPERATIONS.md §Backup, TECHNICAL.md §15 |
| Feb 15 2026 | Multiple undocumented services discovered (3002, 8880) | Security risk: exposed services without authentication | Added to documentation, scheduled firewall implementation | TECHNICAL.md §13.1 |

> Add new incidents here immediately after they occur, and log full details plus remediation steps in SECURITY_INCIDENT.md and INCIDENT_RESPONSE.md.

## Technical Infrastructure (Summary)

A complete system inventory lives in **TECHNICAL.md** and currently includes:

- **Git Hosting**: Gitea 1.23.3 on port 3000 (PID 1632, user `git`, config `/opt/gitea/app.ini`)
- **Forgejo Instance**: Clean install on port 3001 awaiting successful migration
- **Server**: Ubuntu 24.04.4 LTS, Linux 6.8.0-100, AMD EPYC-Genoa (2 vCPU, 3.7 GiB RAM, 75 GB disk)
- **Networking**: SSH on port 22 (key-only), public IP `46.224.129.229`, firewall status TBD
- **Workspace**: `/root/.openclaw/workspace` for assistant projects, `/root/company-structure` for this repo
- **CI/CD**: Gitea Actions currently stuck "Waiting"; temporary manual runner script `/opt/gitea/ci-runner.sh`
- **Automation Scripts**: Daily/Monthly backup scripts + 30-minute system health monitor (see OPERATIONS.md for scheduling and TECHNICAL.md §15)

Consult TECHNICAL.md for command references, backup locations, and troubleshooting steps.

## Security Posture

### Current Security Status (Feb 15, 2026)

**⚠️ CRITICAL SECURITY RISKS IDENTIFIED**:
1. **No Firewall**: Exposed ports (22, 3000, 3002, 8880) accessible from any IP
2. **Unauthenticated Services**: Ports 3002 (Nuxt.js) and 8880 (DeepInfra proxy) publicly accessible without authentication
3. **No Fail2Ban**: SSH brute force protection not implemented
4. **Identity Verification**: Recent incident highlights need for enhanced verification protocols

**✅ Security Controls Implemented**:
1. **SSH Key Authentication**: Password authentication disabled
2. **Regular Backups**: Incremental daily and monthly full backups operational
3. **System Monitoring**: Health check scripts running
4. **Credential Rotation**: Post-incident SSH keys and GitHub PAT rotated
5. **Documentation**: Comprehensive security policies and incident response procedures
6. **Security Hardening Scripts**: Complete automation suite for security implementation

**🔧 Immediate Security Actions Required**:
1. **Deploy UFW firewall** with least-privilege rules using `security-hardening.sh --install-firewall`
2. **Install Fail2Ban** for SSH protection using `security-hardening.sh --install-fail2ban`
3. **Harden SSH configuration** using `security-hardening.sh --harden-ssh`
4. **Restrict unauthorized services** (3002, 8880) to localhost
5. **Implement enhanced logging** using `security-hardening.sh --setup-logging`
6. **Apply system-wide hardening** using `security-hardening.sh --harden-system`
7. **Establish comprehensive backups** using `comprehensive-backup.sh`

### Security Automation Suite
The repository now includes comprehensive security automation scripts:

**Available Scripts**:
- `security-hardening.sh`: Complete security hardening for Ubuntu 24.04 LTS
- `comprehensive-backup.sh`: Full system backup with retention policies
- `incident-response-playbook.md`: Detailed procedures for security incidents
- Enhanced `TECHNICAL.md` with security implementation guidance
- Updated `OPERATIONS.md` with security hardening procedures

**Implementation Priority**:
1. **Critical**: Firewall, Fail2Ban, SSH hardening, service restriction
2. **High**: Enhanced logging, system hardening, backup implementation
3. **Medium**: Security monitoring, incident response automation
4. **Low**: Compliance documentation, threat intelligence integration

For detailed procedures, refer to **TECHNICAL.md §16** and **OPERATIONS.md Security Hardening Procedures**.

For detailed procedures, refer to **SECURITY.md** and **TECHNICAL.md §13**.

## Development Workflow

### Current Priorities
1. Complete OpenClaw interface within `experience-portal`
2. Resolve Discord DM integration issues flagged by Yukine
3. Stand up a reliable CI/CD pipeline (runner install or enhanced manual scripts)
4. Expand documentation (this repo) and knowledge transfer materials
5. Continue assistant upgrades toward Veld's CEO-support objectives

### GitHub & Gitea Accounts
- **RemBotClawBot (GitHub)**: Public-facing identity + automation experiments; ensure SSH keys remain synced
- **Gitea / Forgejo**: Repositories owned by `Rem` account when possible; transfer assets before disabling users (e.g., Gerard)
- **Credentials**: Strong passwords stored outside repo; never commit secrets

## Operational Procedures

**OPERATIONS.md** codifies:

- Morning/midday/evening health checks with concrete shell commands
- Backup scripts (daily incremental + monthly full) and retention windows
- User onboarding/offboarding, including identity verification and SSH provisioning
- Change management workflows (standard vs. emergency) with approval routing (Veld only)
- Communication cadence: heartbeat updates, weekly syncs, monthly reviews, emergency escalation templates

## Future Expansion

- Finish Forgejo migration once schema compatibility is resolved
- Install and configure a proper Actions runner (TypeScript/Nuxt dependencies, container isolation)
- Deploy monitoring + alerting stack (system metrics, log aggregation, incident dashboards)
- Harden security (firewall configuration, Fail2Ban, MFA, improved credential rotation)
- Build onboarding kits for future developers and assistant operators, leveraging OPERATIONS.md & INCIDENT_RESPONSE.md

---

*Update this README whenever authority changes, new incidents occur, or infrastructure milestones are reached.*
